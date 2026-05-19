*** Settings ***
Resource         common_keywords.robot
Resource         cart_page_keywords.robot
Resource         ../variables/product_details_page_variables.robot

*** Keywords ***
Validate Product Details Core Elements
    Wait Until Element Is Visible    ${PRODUCT_TITLE_LOCATOR}    20s
    Element Should Be Visible        ${PRODUCT_TITLE_LOCATOR}
    Element Should Be Visible        ${PRODUCT_PRICE_LOCATOR}
    Element Should Be Visible        ${PRODUCT_RATING_LOCATOR}

Validate Product Description Sections
    Element Should Be Visible        ${PRODUCT_FEATURE_BULLETS_LOCATOR}
    ${has_overview}=    Run Keyword And Return Status    Element Should Be Visible    ${PRODUCT_OVERVIEW_LOCATOR}
    ${has_details}=     Run Keyword And Return Status    Element Should Be Visible    ${PRODUCT_DETAILS_LOCATOR}
    ${has_description_section}=    Evaluate    $has_overview or $has_details
    Should Be True                  ${has_description_section}    Expected at least one product description section to be visible.

Get Current Product Title
    Wait Until Element Is Visible    ${PRODUCT_TITLE_LOCATOR}    20s
    ${product_title}=    Get Text    ${PRODUCT_TITLE_LOCATOR}
    RETURN    ${product_title}

Get Current Product Price
    Wait Until Element Is Visible    ${PRODUCT_PRICE_LOCATOR}    20s
    ${product_price_text}=    Get Text    ${PRODUCT_PRICE_LOCATOR}
    ${product_price}=    Convert Price Text To Number    ${product_price_text}
    RETURN    ${product_price}

Add Current Product To Cart As Guest
    ${initial_cart_count}=    Get Current Cart Count
    ${clicked}=    Run Keyword And Return Status    Click Button    ${ADD_TO_CART_PRIMARY_LOCATOR}
    IF    not ${clicked}
        ${clicked}=    Run Keyword And Return Status    Click Button    ${ADD_TO_CART_SECONDARY_LOCATOR}
    END
    IF    not ${clicked}
        Click Button    ${ADD_TO_CART_NAME_LOCATOR}
    END
    Wait Until Keyword Succeeds      15x    1s    Cart Count Should Be Updated    ${initial_cart_count}
    ${updated_cart_count}=    Get Current Cart Count
    RETURN    ${initial_cart_count}    ${updated_cart_count}

Capture Product Details Pass Screenshot
    Capture Top Of Page Screenshot   ${PRODUCT_DETAILS_SCREENSHOT_NAME}

