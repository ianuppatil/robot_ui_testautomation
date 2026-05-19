Robot UI Test Automation Docs
This folder contains the project documentation for the Amazon.de UI automation suite.

Documentation Index
docs/README.md (this file): quick navigation and setup summary
docs/Test_Flows_and_Test_Cases.docs: detailed test flows, test cases, expected outcomes, and page-object mapping
Quick Summary
Framework: Robot Framework + SeleniumLibrary
Target site: https://www.amazon.de/
Browser: Chrome (headed or headless)
Execution modes:
local headed
local headless
GitLab CI headless pipeline
Quick Run Commands
Install dependencies:

python -m pip install -r requirements.txt
Run all tests (headed):

robot -T tests\amazon_homepage.robot
Run all tests (headless):

robot -T --variable HEADLESS:true --variable BROWSER:chrome tests\amazon_homepage.robot
Audience Notes
If you are a developer/test engineer, start with docs/Test_Flows_and_Test_Cases.docs section Technical Mapping.
If you are a reviewer/business stakeholder, start with docs/Test_Flows_and_Test_Cases.docs section Business View of Test Flows.
