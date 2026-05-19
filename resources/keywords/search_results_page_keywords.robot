*** Settings ***
Resource         common_keywords.robot
Resource         ../variables/common_variables.robot
Resource         ../variables/home_page_variables.robot
Resource         ../variables/search_results_page_variables.robot
Resource         ../variables/product_details_page_variables.robot

*** Keywords ***
Validate Product Search Results
    [Arguments]    ${product_name}
    Wait Until Element Is Visible    ${SEARCH_RESULTS_LOCATOR}    20s
    ${results_count}=    Get Element Count    ${SEARCH_RESULTS_LOCATOR}
    Should Be True                  ${results_count} > 0    No search results were displayed for ${product_name}.
    ${search_box_value}=    Get Value    ${SEARCH_BAR_LOCATOR}
    Should Contain                  ${search_box_value}    ${product_name}

Get First Search Result Product Url
    ${product_url}=    Execute JavaScript
    ...    const links = Array.from(document.querySelectorAll("[data-component-type='s-search-result'] .a-link-normal.s-line-clamp-2.s-link-style.a-text-normal"));
    ...    const match = links.find(link => {
    ...        const href = link.href || '';
    ...        const hasText = (link.textContent || '').trim().length > 0;
    ...        const resultCard = link.closest("[data-component-type='s-search-result']");
    ...        const hasPrice = !!resultCard && !!resultCard.querySelector('.a-price .a-price-whole') && !!resultCard.querySelector('.a-price .a-price-fraction');
    ...        return hasText && hasPrice && href && !href.includes('/sspa/');
    ...    });
    ...    return match ? match.href : null;
    Should Not Be Empty              ${product_url}
    RETURN    ${product_url}

Open First Search Result Product Details Page
    ${product_url}=    Get First Search Result Product Url
    Go To                            ${product_url}
    Wait Until Element Is Visible    ${PRODUCT_TITLE_LOCATOR}    20s

Apply Apple Brand Filter
    Handle Cookie Consent If Present
    Wait Until Element Is Visible    ${APPLE_BRAND_FILTER_LOCATOR}    20s
    Scroll Element Into View         ${APPLE_BRAND_FILTER_LOCATOR}
    ${brand_filter_url}=    Get Element Attribute    ${APPLE_BRAND_FILTER_LOCATOR}    href
    Go To                            ${brand_filter_url}
    Wait Until Element Is Visible    ${SEARCH_RESULTS_LOCATOR}    20s

Apply Sort Option
    [Arguments]    ${sort_value}
    Select From List By Value        ${SEARCH_RESULT_SORT_DROPDOWN_LOCATOR}    ${sort_value}
    Wait Until Keyword Succeeds      10x    1s    Sort Option Should Be Selected    ${sort_value}
    Wait Until Element Is Visible    ${SEARCH_RESULTS_LOCATOR}    20s

Sort Option Should Be Selected
    [Arguments]    ${sort_value}
    ${selected_sort}=    Get Selected List Value    ${SEARCH_RESULT_SORT_DROPDOWN_LOCATOR}
    Should Be Equal                  ${selected_sort}    ${sort_value}

Validate Filtered Products Match Selected Criteria
    [Arguments]    ${product_name}    ${brand_name}
    Validate Product Search Results  ${product_name}
    ${current_url}=    Get Location
    Should Contain                   ${current_url}    p_123%3A110955
    ${titles}=    Get Top Result Titles    5
    ${title_count}=    Get Length    ${titles}
    Should Be True                   ${title_count} > 0    No product titles were available after filtering.
    FOR    ${title}    IN    @{titles}
        Should Match Regexp          ${title}    (?i).*${brand_name}.*
    END

Validate Results Sorted By Price Ascending
    ${current_url}=    Get Location
    Should Contain                   ${current_url}    s=${SORT_LOW_TO_HIGH_VALUE}
    Sort Option Should Be Selected   ${SORT_LOW_TO_HIGH_VALUE}
    ${results_count}=    Get Element Count    ${SEARCH_RESULTS_LOCATOR}
    Should Be True                   ${results_count} > 0    No search results were available after sorting.

Get Top Result Titles
    [Arguments]    ${count}=5
    ${titles}=    Execute JavaScript
    ...    return Array.from(document.querySelectorAll("[data-component-type='s-search-result'] h2 span"))
    ...      .map(item => item.textContent.trim())
    ...      .filter(Boolean)
    ...      .slice(0, arguments[0]);
    ...    ARGUMENTS    ${count}
    RETURN    ${titles}

Capture Search Results Pass Screenshot
    Capture Top Of Page Screenshot   ${SEARCH_RESULTS_SCREENSHOT_NAME}

Capture Filtered Results Pass Screenshot
    Capture Top Of Page Screenshot   ${FILTERED_RESULTS_SCREENSHOT_NAME}

