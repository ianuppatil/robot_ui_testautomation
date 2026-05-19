*** Settings ***
Documentation    Smoke test for Amazon.de homepage UI elements.
Resource         ../resources/keywords/amazon_all_keywords.robot

Test Setup       Open Amazon Homepage
Test Teardown    Close Browser

*** Test Cases ***
01 Verify Homepage Loads Successfully
    [Documentation]    Launch Amazon.de and validate key homepage elements.
    Handle Cookie Consent If Present
    Validate Amazon Homepage Core Elements
    Validate Amazon Homepage Metadata
    Capture Homepage Pass Screenshot

02 Verify Product Search Functionality
    [Documentation]    Search for a product and verify search results are displayed correctly.
    Handle Cookie Consent If Present
    Search For Product               ${SEARCH_TERM}
    Validate Product Search Results  ${SEARCH_TERM}
    Capture Search Results Pass Screenshot

03 Verify Product Details Page Validation
    [Documentation]    Open a product from search results and validate key product details sections.
    Handle Cookie Consent If Present
    Search For Product                  ${PRODUCT_DETAILS_SEARCH_TERM}
    Open First Search Result Product Details Page
    Validate Product Details Core Elements
    Validate Product Description Sections
    Capture Product Details Pass Screenshot

04 Verify Add to Cart Without Login (Guest Flow)
    [Documentation]    Add a product to the cart as a guest and validate cart count, product, quantity, and subtotal.
    Handle Cookie Consent If Present
    Search For Product                  ${CART_SEARCH_TERM}
    Open First Search Result Product Details Page
    ${product_title}=                   Get Current Product Title
    ${product_price}=                   Get Current Product Price
    ${initial_cart_count}    ${updated_cart_count}=    Add Current Product To Cart As Guest
    Open Cart Page
    Validate Guest Cart Contents        ${product_title}    ${product_price}    ${EXPECTED_CART_QUANTITY}
    Capture Cart Pass Screenshot

05 Verify Search Filters & Sorting
    [Documentation]    Apply the Apple brand filter, then verify results and low-to-high sorting.
    Handle Cookie Consent If Present
    Search For Product                               ${SEARCH_TERM}
    Apply Apple Brand Filter
    Apply Sort Option                                ${SORT_LOW_TO_HIGH_VALUE}
    Validate Filtered Products Match Selected Criteria    ${SEARCH_TERM}    ${APPLE_BRAND}
    Validate Results Sorted By Price Ascending
    Capture Filtered Results Pass Screenshot

