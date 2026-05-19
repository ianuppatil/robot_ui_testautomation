*** Settings ***
Resource         common_keywords.robot
Resource         ../variables/cart_page_variables.robot

*** Keywords ***
Get Current Cart Count
    Wait Until Element Is Visible    ${NAV_CART_COUNT_LOCATOR}    20s
    ${cart_count_text}=    Get Text    ${NAV_CART_COUNT_LOCATOR}
    ${cart_count}=    Convert To Integer    ${cart_count_text}
    RETURN    ${cart_count}

Cart Count Should Be Updated
    [Arguments]    ${initial_cart_count}
    ${current_cart_count}=    Get Current Cart Count
    ${expected_cart_count}=    Evaluate    int($initial_cart_count) + 1
    Should Be Equal As Integers       ${current_cart_count}    ${expected_cart_count}

Open Cart Page
    Click Element                     ${NAV_CART_LINK_LOCATOR}
    Wait Until Element Is Visible     ${CART_SUBTOTAL_AMOUNT_LOCATOR}    20s

Validate Guest Cart Contents
    [Arguments]    ${product_title}    ${product_price}    ${expected_quantity}
    ${cart_count}=    Get Current Cart Count
    Should Be Equal As Integers       ${cart_count}    ${expected_quantity}
    ${cart_item_title}=    Get Text    ${CART_ITEM_TITLE_LOCATOR}
    ${expected_title_prefix}=    Evaluate    ' '.join($product_title.split()[:2])
    Should Contain                    ${cart_item_title}    ${expected_title_prefix}
    ${cart_quantity_text}=    Get Text    ${CART_ITEM_QUANTITY_LOCATOR}
    Should Be Equal As Integers       ${cart_quantity_text}    ${expected_quantity}
    ${cart_item_price_text}=    Get Text    ${CART_ITEM_PRICE_LOCATOR}
    ${cart_item_price}=    Convert Price Text To Number    ${cart_item_price_text}
    Should Be Equal As Numbers        ${cart_item_price}    ${product_price}
    ${cart_subtotal_text}=    Get Text    ${CART_SUBTOTAL_AMOUNT_LOCATOR}
    ${cart_subtotal}=    Convert Price Text To Number    ${cart_subtotal_text}
    ${expected_subtotal}=    Evaluate    round(float($product_price) * int($expected_quantity), 2)
    Should Be Equal As Numbers        ${cart_subtotal}    ${expected_subtotal}

Capture Cart Pass Screenshot
    Capture Top Of Page Screenshot   ${CART_SCREENSHOT_NAME}

