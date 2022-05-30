#!/usr/bin/env bash
set -e

PACT_CLI="docker run --rm pactfoundation/pact-cli:latest ";
EXECUTOR="broker "
COMMAND=''
URI=''
COMMAND_TO_EXECUTE=''
GITHUB_URI=''
HEADERS=''
REQUEST=''
DATA=''
PARTICIPANT_DETAILS=''
PROVIDER_DETAILS=''
CONSUMER_DETAILS=''
EVENT_LIST=''
WEBHOOK_DESCRIPTION=''
BROKER_AUTHENTICATION=''
TEAM_DETAILS=''


testing() {
  echo ""
  echo "This is to test the docker build"
  echo "$PACT_CLI $EXECUTOR $COMMAND"
  echo "$INPUT_ACTION"
  echo "$INPUT_WEBHOOK_TYPE"
}

command_setup() {
  commander=""
  echo "provided action: $INPUT_ACTION"
  if [[ "$INPUT_ACTION" == "create" || "$INPUT_ACTION" == "update" ]]
  then
    if [ "$INPUT_ACTION" == "create" ]
    then
      commander="create-webhook"
      echo "Executing create-webhook command"
    elif [ "$INPUT_ACTION" == "update" ]
    then
      commander="create-or-update-webhook"
      echo "Executing create-or-update-webhook command"
    fi
  else
    echo "Action(input value) is ,it must be either 'create' or 'update'"
    exit 1
  fi
  echo "command: $commander"
}

uri_setup() {
  uri=''
  if [ "$INPUT_WEBHOOK_TYPE" == 'trigger_provider_job' ] || [ "$INPUT_WEBHOOK_TYPE" == 'consumer_commit_status' ]
  then
    if [ "$INPUT_WEBHOOK_TYPE" == 'trigger_provider_job' ]
    then
      uri="'https://api.github.com/repos/$INPUT_ORGANIZATION/$INPUT_REPOSITORY/dispatches'"
      echo "$uri"
    elif [ "$INPUT_WEBHOOK_TYPE" == 'consumer_commit_status' ]
    then
      uri="'https://api.github.com/repos/$INPUT_ORGANIZATION/$INPUT_REPOSITORY/dispatches'"
      echo "$uri"
    fi
  else
    echo "Webhook_type(input value) is $INPUT_WEBHOOK_TYPE , it must be either 'trigger_provider_job' or 'consumer_commit_status'"
    exit 1
  fi
  echo "$uri"
}

create_webhook() {
  docker run --rm pactfoundation/pact-cli:latest broker \
                      "$COMMAND_TO_EXECUTE"  "$URI"\
                      "$GITHUB_URI" \
                      "$HEADERS" \
                      "'Authorization: Bearer ${INPUT_GITHUB_PERSONAL_ACCESS_TOKEN}'" \
                      "$REQUEST" \
                      "$DATA" \
                      "$PROVIDER_DETAILS"  "$CONSUMER_DETAILS" \
                      "$EVENT_LIST" \
                      "$WEBHOOK_DESCRIPTION" \
                      "$INPUT_BROKER_BASE_URL" \
                      "$BROKER_AUTHENTICATION" \
                      "$TEAM_DETAILS"

#  docker run --rm pactfoundation/pact-cli:latest broker create-webhook 'https://api.github.com/repos/rajnavakotiikea/example-provider/dispatches' \
#                    --header 'Content-Type: application/json' 'Accept: application/vnd.github.everest-preview+json' \
#                    "'Authorization: Bearer ${INPUT_GITHUB_TOKEN}'" \
#                    --request POST \
#                    --data '{ "event_type": "pact_changed", "client_payload": { "pact_url": "${pactbroker.pactUrl}" } }' \
#                    --provider pactflow-example-provider \
#                    --contract-content-changed \
#                    --description "Pact content changed for pactflow-example-provider" \
#                    --broker-base-url https://sampleautoamtiontestraj.pactflow.io \
#                    --broker-token GglUlzHa8Egn_fpkhzZQLw
}




broker_auth_setup() {
  authentication=""
  echo "provided token: $INPUT_BROKER_TOKEN"
  if [ -z "$INPUT_BROKER_TOKEN" ]
  then
    echo "broker token not provided. checking for broker username and password details"
    if [ -z "$INPUT_BROKER_USERNAME" ] || [ -z "$INPUT_BROKER_PASSWORD" ]
    then
      echo "either token or username + password has to be provided"
      exit 1
    else
      echo "broker username and password provided for authentication"
      authentication="--broker-username $INPUT_BROKER_USERNAME --broker-password $INPUT_BROKER_PASSWORD"
    fi
  else
    echo "broker token provided for authentication"
    authentication="--broker-token $INPUT_BROKER_TOKEN"
  fi
  echo "$authentication"
}

testing
#broker_auth="$(broker_auth_setup)"
#echo "$broker_auth"
command_setup
command_value="$(command_setup)"
echo "$command_value"
#uri_value="$(uri_setup)"
#echo "$uri_value"