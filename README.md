

# Before you start

https://production-engineering.kbuild.msap.io/journey/journey-build/README.html

- Create a repo in https://github.com/mulesoft using prodEng bot command >/prodeng create-repo
    - Organization: mulesoft
    - Team: team-ms-interpreted-connectivity
    - Jenkins Job: Not Needed
    - Unified Pipeline Onboarding: Yes
    - Strategy: mvn-lib
    - Product Name: interpreted-connectivity
    - Component Name: <your saas name> eg: jira
    - Asset type: None
    - Template: None

- Onboard to kilonova
``` yaml
product: interpreted-connectivity
component: your-component
version: "0.1"
profile: interpretedConnectivity

builder:
  name: java-maven-lib
  version: 11

componentType: library

notifications:
  slackChannel: your-channel-bot
```

# Create secrets and consume secrets

## Step 1

- Go to https://dragon-ci.kbuild.msap.io/charlie/job/interpreted-connectivity/job/interpreted-connectivity-secrets/ and build the project with parameters:
    - ACTION: WRITE
    - SECRET_NAME: your secret name with mid dashes and in lowercase letters, just-like-this
    - SECRET_VALUE: click the Change Password button and insert your secret value
    - SECRET_DESC: a description for your secret
    - IS_PRODUCTION: if you check this, the secret will be available for ALL your branches. If it’s not, it’ll be available ONLY to branches like master / main. IT IS NOT MANDATORY to check this for adding a new secret, it only changes the visibility of it to the branches.
- Build the pipeline
- The build has an interactive step that will require approval from a DIFFERENT user than the one that started the build.

## Step 2

- Create a PR in https://github.com/mulesoft/kilonova-pipeline-customizations/
    - In the file for your project (i.e. interpreted-connectivity/jira/profile.yaml) create an input FOR EACH secret with the following content:
        - name: use THE SAME NAME used in SECRET_NAME when the secrets job was ran
        - type: token
        - id: same value for name
          Ask for approval using the bot /prodeng ask command in slack, providing the PR URL

- Once approved, the PR should be merged automatically and the secrets should be available in a few minutes
- [Example PR](https://github.com/mulesoft/kilonova-pipeline-customizations/pull/632/files)
``` yaml
- name: run-tests-test
arguments:
  inputs:
    - name: interpreted-connectivity-jira-username
      type: token
      id: interpreted-connectivity-jira-username
    - name: interpreted-connectivity-jira-password
      type: token
      id: interpreted-connectivity-jira-password
    - name: interpreted-connectivity-jira-base-uri
      type: token
      id: interpreted-connectivity-jira-base-uri
```
## Step 3

- Use the secrets as environment variables in your code.

**_NOTE:_** that the name of the secret will be transformed to camel case. For example, interpreted-connectivity-jira-username will be available as **INTERPRETED_CONNECTIVITY_JIRA_USERNAME**

```
baseUri: dw::System::envVars().INTERPRETED_CONNECTIVITY_JIRA_BASE_URI default "http://localhost:8081"

username: dw::System::envVars().INTERPRETED_CONNECTIVITY_JIRA_USERNAME default "ze"
	
password: dw::System::envVars().INTERPRETED_CONNECTIVITY_JIRA_PASSWORD default "token"
```



[Documentation](https://docs.google.com/document/d/1Is2xE2bhhX1H-Gvjmqarq5AwLCSBGnCUut3h5AsJIww)
