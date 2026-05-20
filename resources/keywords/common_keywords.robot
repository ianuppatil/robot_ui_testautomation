*** Settings ***
Library          SeleniumLibrary    timeout=10s
Library          OperatingSystem
Resource         ../variables/common_variables.robot
Resource         ../variables/home_page_variables.robot

*** Keywords ***
Open Amazon Homepage
    ${has_browser}=    Run Keyword And Return Status    Get Window Handles
    IF    not ${has_browser}
        Open Amazon Browser Session
    END
    Go To    ${AMAZON_URL}
    Wait Until Location Contains    amazon.de    20s
    Wait Until Keyword Succeeds      3x    10s    Ensure Amazon Homepage Is Ready

Open Amazon Browser Session
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    modules=sys,selenium.webdriver
    ${headless_enabled}=    Evaluate    str($HEADLESS).strip().lower() in ('1', 'true', 'yes', 'y')
    ${chrome_binary_set}=    Evaluate    bool(str($CHROME_BINARY).strip())
    ${local_driver_path}=    Set Variable    ${EXECDIR}${/}chromedriver.exe
    ${has_local_driver}=    Run Keyword And Return Status    File Should Exist    ${local_driver_path}
    ${has_custom_driver}=    Run Keyword And Return Status    Should Not Be Empty    ${DRIVER_PATH}
    Call Method    ${chrome_options}    add_argument    --start-maximized
    IF    ${headless_enabled}
        ${chrome_options}=    Evaluate    $chrome_options.add_argument('--headless=new') or $chrome_options
        ${chrome_options}=    Evaluate    $chrome_options.add_argument('--window-size=1920,1080') or $chrome_options
        Call Method    ${chrome_options}    add_argument    --disable-dev-shm-usage
        Call Method    ${chrome_options}    add_argument    --no-sandbox
    END
    IF    ${chrome_binary_set}
        ${chrome_options}=    Evaluate    setattr($chrome_options, 'binary_location', str($CHROME_BINARY).strip()) or $chrome_options
    END
    IF    ${has_custom_driver}
        Open Browser    about:blank    ${BROWSER}    options=${chrome_options}    executable_path=${DRIVER_PATH}
    ELSE IF    ${has_local_driver}
        Open Browser    about:blank    ${BROWSER}    options=${chrome_options}    executable_path=${local_driver_path}
    ELSE
        Open Browser    about:blank    ${BROWSER}    options=${chrome_options}
    END
Handle Cookie Consent If Present
    ${is_visible}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${COOKIE_ACCEPT_LOCATOR}    5s
    IF    ${is_visible}
        Click Button    ${COOKIE_ACCEPT_LOCATOR}
    END

Capture Top Of Page Screenshot
    [Arguments]    ${screenshot_name}
    Execute JavaScript               window.scrollTo(0, 0)
    Wait Until Keyword Succeeds      5x    500ms    Page Should Be Scrolled To Top
    Wait Until Element Is Visible    ${LOGO_LOCATOR}    10s
    Capture Page Screenshot          ${screenshot_name}

Page Should Be Scrolled To Top
    ${scroll_y}=    Execute JavaScript    return window.pageYOffset
    Should Be Equal As Numbers       ${scroll_y}    0

Convert Price Text To Number
    [Arguments]    ${price_text}
    ${normalized_price}=    Evaluate    __import__('re').sub(r'[^0-9,\.]', '', '''${price_text}''').replace('.', '').replace(',', '.')
    ${price_number}=    Convert To Number    ${normalized_price}
    RETURN    ${price_number}

Ensure Amazon Homepage Is Ready
    ${has_captcha}=    Run Keyword And Return Status
    ...    Page Should Contain Element    css=input#captchacharacters, form[action*='validateCaptcha']
    IF    ${has_captcha}
        Handle Amazon Challenge Page    Homepage readiness check
    END
    ${search_ready}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${SEARCH_BAR_LOCATOR}    10s
    ${logo_ready}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOGO_LOCATOR}    10s
    ${logo_fallback_ready}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${LOGO_FALLBACK_LOCATOR}    10s
    ${is_ready}=    Evaluate    $search_ready or $logo_ready or $logo_fallback_ready
    Should Be True    ${is_ready}    Amazon homepage did not become ready in time.

Handle Amazon Challenge Page
    [Arguments]    ${context}=Unknown context
    Capture Page Screenshot
    ${skip_on_challenge}=    Evaluate    str($SKIP_ON_AMAZON_CHALLENGE).strip().lower() in ('1', 'true', 'yes', 'y')
    IF    ${skip_on_challenge}
        Skip    Amazon challenge/captcha detected in ${context}. Marking as skipped for CI stability.
    END
    Fail    Amazon bot/captcha page detected in ${context}. Retry run or use a runner/IP with normal access to amazon.de.

