*** Variables ***
${SEARCH_RESULTS_SCREENSHOT_NAME}      amazon_search_results_pass.png
${FILTERED_RESULTS_SCREENSHOT_NAME}    amazon_filtered_sorted_results_pass.png

${SEARCH_RESULTS_LOCATOR}              css=[data-component-type="s-search-result"]
${SEARCH_RESULT_PRODUCT_LINK_LOCATOR}  css=[data-component-type="s-search-result"] .a-link-normal.s-line-clamp-2.s-link-style.a-text-normal
${SEARCH_RESULT_SORT_DROPDOWN_LOCATOR}    id=s-result-sort-select
${APPLE_BRAND_FILTER_LOCATOR}          xpath=(//div[@id='s-refinements']//span[normalize-space()='Brands']/following::a[normalize-space()='Apple' or .//span[normalize-space()='Apple']])[1]

