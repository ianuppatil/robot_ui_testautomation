*** Settings ***
Resource         common_keywords.robot
Resource         ../variables/common_variables.robot
Resource         ../variables/home_page_variables.robot

*** Keywords ***
Validate Amazon Homepage Core Elements
    Wait Until Element Is Visible    ${SEARCH_BAR_LOCATOR}    40s
    ${logo_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${LOGO_LOCATOR}
    IF    not ${logo_visible}
        Element Should Be Visible    ${LOGO_FALLBACK_LOCATOR}
    END
    ${nav_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${NAV_MENU_LOCATOR}
    IF    not ${nav_visible}
        Element Should Be Visible    ${NAV_MENU_FALLBACK_LOCATOR}
    END
    Scroll Element Into View         ${FOOTER_LOCATOR}
    Element Should Be Visible        ${FOOTER_LOCATOR}

Validate Amazon Homepage Metadata
    ${page_title}=    Get Title
    Should Contain                   ${page_title}    ${EXPECTED_TITLE_PART}
    ${current_url}=    Get Location
    Should Start With                ${current_url}    ${AMAZON_URL}

Search For Product
    [Arguments]    ${product_name}
    Wait Until Element Is Visible    ${SEARCH_BAR_LOCATOR}    40s
    Clear Element Text               ${SEARCH_BAR_LOCATOR}
    Input Text                       ${SEARCH_BAR_LOCATOR}    ${product_name}
    Press Keys                       ${SEARCH_BAR_LOCATOR}    ENTER

Capture Homepage Pass Screenshot
    Capture Top Of Page Screenshot   ${PASS_SCREENSHOT_NAME}

