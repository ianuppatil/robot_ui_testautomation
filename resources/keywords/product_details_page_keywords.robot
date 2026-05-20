*** Settings ***
Resource         common_keywords.robot
Resource         cart_page_keywords.robot
Resource         ../variables/product_details_page_variables.robot

*** Keywords ***
Validate Product Details Core Elements
    Wait Until Element Is Visible    ${PRODUCT_TITLE_LOCATOR}    20s
    Element Should Be Visible        ${PRODUCT_TITLE_LOCATOR}
    ${product_price_text}=           Get Current Product Price Text
    Should Not Be Empty              ${product_price_text}
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
    ${product_price_text}=    Get Current Product Price Text
    ${product_price}=    Convert Price Text To Number    ${product_price_text}
    RETURN    ${product_price}

Get Current Product Price Text
    ${price_candidates}=    Get Product Price Text Candidates
    ${candidate_count}=    Get Length    ${price_candidates}
    IF    ${candidate_count} > 0
        RETURN    ${price_candidates}[0]
    END
    Handle Product Page Without Visible Price

Get Product Price Text Candidates
    ${price_candidates}=    Execute JavaScript
    ...    const selectors = [
    ...      '#corePriceDisplay_desktop_feature_div .a-price .a-offscreen',
    ...      '#corePrice_feature_div .a-price .a-offscreen',
    ...      '#corePrice_desktop .a-price .a-offscreen',
    ...      '#apex_desktop .a-price .a-offscreen',
    ...      '.priceToPay .a-offscreen',
    ...      '.apexPriceToPay .a-offscreen',
    ...      '.reinventPricePriceToPayMargin .a-offscreen',
    ...      '#tp_price_block_total_price_ww .a-offscreen',
    ...      'span.a-price.aok-align-center .a-offscreen',
    ...      'span.a-price .a-offscreen',
    ...      '[data-a-color="price"] .a-offscreen'
    ...    ];
    ...    const values = [];
    ...    for (const selector of selectors) {
    ...      const nodes = Array.from(document.querySelectorAll(selector));
    ...      for (const node of nodes) {
    ...        const text = ((node.textContent || node.innerText || '') || '').trim();
    ...        if (text && /[0-9]/.test(text)) {
    ...          values.push(text);
    ...        }
    ...      }
    ...    }
    ...    const containers = Array.from(document.querySelectorAll('#corePriceDisplay_desktop_feature_div, #corePrice_feature_div, #corePrice_desktop, #apex_desktop, #ppd, #dp-container'));
    ...    for (const container of containers) {
    ...      const text = (container.innerText || '').trim();
    ...      if (text && /[0-9]/.test(text)) {
    ...        values.push(text);
    ...      }
    ...    }
    ...    return values;
    ${price_candidates}=    Evaluate    $price_candidates if isinstance($price_candidates, list) else []
    RETURN    ${price_candidates}


Handle Product Page Without Visible Price
    ${has_challenge}=    Execute JavaScript
    ...    const bodyText = (document.body && document.body.innerText || '').toLowerCase();
    ...    return Boolean(
    ...      document.querySelector("input#captchacharacters") ||
    ...      document.querySelector("form[action*='validateCaptcha']") ||
    ...      bodyText.includes('robot check') ||
    ...      bodyText.includes('enter the characters you see below')
    ...    );
    IF    ${has_challenge}
        Handle Amazon Challenge Page    Product details price extraction
    END
    Capture Page Screenshot
    Fail    Product price was not available on the product details page.

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

