*** Settings ***
Resource         common_keywords.robot
Resource         ../variables/common_variables.robot
Resource         ../variables/home_page_variables.robot
Resource         ../variables/search_results_page_variables.robot
Resource         ../variables/product_details_page_variables.robot

*** Keywords ***
Validate Product Search Results
    [Arguments]    ${product_name}
    Wait Until Keyword Succeeds      6x    10s    Ensure Search Results Page Is Ready
    ${primary_count}=    Get Element Count    ${SEARCH_RESULTS_LOCATOR}
    ${fallback_count}=    Get Element Count    ${SEARCH_RESULTS_FALLBACK_LOCATOR}
    ${results_count}=    Evaluate    max(int($primary_count), int($fallback_count))
    Should Be True                  ${results_count} > 0    No search results were displayed for ${product_name}.
    ${search_box_value}=    Get Value    ${SEARCH_BAR_LOCATOR}
    Should Contain                  ${search_box_value}    ${product_name}

Get First Search Result Product Url
    ${product_url}=    Execute JavaScript
    ...    const links = Array.from(document.querySelectorAll("[data-component-type='s-search-result'] .a-link-normal.s-line-clamp-2.s-link-style.a-text-normal, [data-cy='title-recipe'] .a-link-normal.s-line-clamp-2.s-link-style.a-text-normal"));
    ...    const match = links.find(link => {
    ...        const href = link.href || '';
    ...        const hasText = (link.textContent || '').trim().length > 0;
    ...        return hasText && href && !href.includes('/sspa/');
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
    ${filter_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${APPLE_BRAND_FILTER_LOCATOR}    8s
    IF    ${filter_visible}
        Scroll Element Into View         ${APPLE_BRAND_FILTER_LOCATOR}
        ${brand_filter_url}=    Get Element Attribute    ${APPLE_BRAND_FILTER_LOCATOR}    href
    ELSE
        ${brand_filter_url}=    Get Apple Brand Filter Url
    END
    Should Not Be Empty              ${brand_filter_url}
    Go To                            ${brand_filter_url}
    Wait Until Keyword Succeeds      6x    10s    Ensure Search Results Page Is Ready

Apply Sort Option
    [Arguments]    ${sort_value}
    Select From List By Value        ${SEARCH_RESULT_SORT_DROPDOWN_LOCATOR}    ${sort_value}
    Wait Until Keyword Succeeds      10x    1s    Sort Option Should Be Selected    ${sort_value}
    Wait Until Keyword Succeeds      6x    10s    Ensure Search Results Page Is Ready

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
    ...    const resultTitles = Array.from(document.querySelectorAll("[data-component-type='s-search-result'] h2 span"));
    ...    if (!resultTitles.length) {
    ...      return [];
    ...    }
    ...    return resultTitles
    ...      .map(item => item.textContent.trim())
    ...      .filter(Boolean)
    ...      .slice(0, Number(arguments[0]) || 5);
    ...    ARGUMENTS    ${count}
    ${titles}=    Evaluate    $titles if isinstance($titles, list) else []
    RETURN    ${titles}

Ensure Search Results Page Is Ready
    Fail If Amazon Challenge Page Is Displayed
    ${primary_ready}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${SEARCH_RESULTS_LOCATOR}    10s
    ${fallback_ready}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${SEARCH_RESULTS_FALLBACK_LOCATOR}    10s
    ${list_ready}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    css=div.s-main-slot    10s
    ${is_ready}=    Evaluate    $primary_ready or $fallback_ready or $list_ready
    Should Be True    ${is_ready}    Search results page did not become ready in time.

Fail If Amazon Challenge Page Is Displayed
    ${has_challenge}=    Execute JavaScript
    ...    const bodyText = (document.body && document.body.innerText || '').toLowerCase();
    ...    return Boolean(
    ...      document.querySelector("input#captchacharacters") ||
    ...      document.querySelector("form[action*='validateCaptcha']") ||
    ...      bodyText.includes('robot check') ||
    ...      bodyText.includes('enter the characters you see below')
    ...    );
    IF    ${has_challenge}
        Capture Page Screenshot
        Fail    Amazon challenge/captcha page detected in CI. Retry run or use a self-hosted runner/IP with stable access.
    END

Get Apple Brand Filter Url
    ${brand_filter_url}=    Execute JavaScript
    ...    const links = Array.from(document.querySelectorAll('#s-refinements a'));
    ...    const match = links.find(link => {
    ...      const text = (link.textContent || '').trim().toLowerCase();
    ...      const href = link.getAttribute('href') || '';
    ...      return text === 'apple' || (text.includes('apple') && href.length > 0);
    ...    });
    ...    return match ? match.href : null;
    RETURN    ${brand_filter_url}

Capture Search Results Pass Screenshot
    Capture Top Of Page Screenshot   ${SEARCH_RESULTS_SCREENSHOT_NAME}

Capture Filtered Results Pass Screenshot
    Capture Top Of Page Screenshot   ${FILTERED_RESULTS_SCREENSHOT_NAME}

