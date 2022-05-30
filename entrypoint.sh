#!/usr/bin/env bash
set -e

PACT_CLI="docker run --rm pactfoundation/pact-cli:latest ";
EXECUTOR="broker "
COMMAND=''
#URI=''
#COMMAND_TO_EXECUTE=''
#GITHUB_URI=''
#HEADERS=''
#REQUEST=''
#DATA=''
#PROVIDER_DETAILS=''
#CONSUMER_DETAILS=''
#EVENT_LIST=''
#WEBHOOK_DESCRIPTION=''
#BROKER_AUTHENTICATION=''
#TEAM_DETAILS=''

command_to_execute=$(command_setup)
uri="$(uri_setup)"
broker_auth="$(broker_auth_setup)"
consumer_args="$(consumer_details)"
provider_args="$(provider_details)"
events_args="$(webhook_events)"




testing() {
  echo ""
  echo "This is to test the docker build"
  echo "$PACT_CLI $EXECUTOR $COMMAND"
  echo "$INPUT_ACTION"
  echo "$INPUT_WEBHOOK_TYPE"
}

validate_args() {
  if [ "$INPUT_ACTION" != "create" ]
  then
    if [ "$INPUT_ACTION" != "update" ]
    then
    echo >&2 "Action(input value) is $INPUT_ACTION,it must be either 'create' or 'update'"
    exit 1
    fi
  fi

  if [ "$INPUT_ACTION" != "trigger_provider_job" ]
  then
    if [ "$INPUT_ACTION" != "consumer_commit_status" ]
    then
    echo "Error - Action(input value) is $INPUT_ACTION,it must be either 'create' or 'update'"
    exit 1
    fi
  fi

  if [ -z "$uri" ]
  then
    echo "Error - Webhook_type(input value) is $INPUT_WEBHOOK_TYPE , it must be either 'trigger_provider_job' or 'consumer_commit_status'"
    exit 1
  fi

  if [ -z "$broker_auth" ]
  then
    echo "Error - either broker token or username+password has to be provided"
    exit 1
  fi

   if [ "$INPUT_WEBHOOK_TYPE" == "trigger_provider_job" ] && [ -z "$provider_args" ]
   then
     echo "Error - provider details has to be provided for 'trigger_provider_job' webhook"
   fi

   if [ "$INPUT_WEBHOOK_TYPE" == "consumer_commit_status" ] && [ -z "$consumer_args" ]
   then
     echo "Error - consumer details has to be provided for 'consumer_commit_status' webhook"
   fi

  if [ -z "$events_args" ]
  then
    echo "Error - no webhooks events are set to 'true'"
    exit 1
  fi
}

webhook_events() {
  events=""
  if [ "$INPUT_CONTRACT_CONTENT_CHANGED" == "true" ]
  then
    events="$events --contract-content-changed"
  fi
  if [ "$INPUT_NO_CONTRACT_CONTENT_CHANGED" == "true" ]
  then
    events="$events --no-contract-content-changed"
  fi
  if [ "$INPUT_CONTRACT_PUBLISHED" == "true" ]
  then
    events="$events --contract-published"
  fi
  if [ "$INPUT_NO_CONTRACT_PUBLISHED" == "true" ]
  then
    events="$events --no-contract-published"
  fi
  if [ "$INPUT_PROVIDER_VERIFICATION_PUBLISHED" == "true" ]
  then
    events="$events --provider-verification-published"
  fi
  if [ "$INPUT_NO_PROVIDER_VERIFICATION_PUBLISHED" == "true" ]
  then
    events="$events --no-provider-verification-published"
  fi
  if [ "$INPUT_PROVIDER_VERIFICATION_FAILED" == "true" ]
  then
    events="$events --provider-verification-failed"
  fi
  if [ "$INPUT_NO_PROVIDER_VERIFICATION_FAILED" == "true" ]
  then
    events="$events --no-provider-verification-failed"
  fi
  if [ "$INPUT_PROVIDER_VERIFICATION_SUCCEEDED" == "true" ]
  then
    events="$events --provider-verification-succeeded"
  fi
  if [ "$INPUT_NO_PROVIDER_VERIFICATION_SUCCEEDED" == "true" ]
  then
    events="$events --no-provider-verification-succeeded"
  fi
  if [ "$INPUT_CONTRACT_REQUIRING_VERIFICATION_PUBLISHED" == "true" ]
  then
    events="$events --contract-requiring-verification-published"
  fi
  if [ "$INPUT_NO_CONTRACT_REQUIRING_VERIFICATION_PUBLISHED" == "true" ]
  then
    events="$events --no-contract-requiring-verification-published"
  fi

  echo "$events"
}

consumer_details() {
  echo "$TESTER"
  consumer_section=""
  echo "provided consumer name: $INPUT_CONSUMER and consumer label: $INPUT_CONSUMER_LABEL"
  if [ -n "$INPUT_CONSUMER" ]
  then
    consumer_section="--consumer $INPUT_CONSUMER"
    if [ -n "$INPUT_CONSUMER_LABEL" ]
    then
      consumer_section="$consumer_section --consumer-label $INPUT_CONSUMER_LABEL"
    fi
  fi
  echo "$consumer_section"
}

provider_details() {
  provider_section=""
  echo "provided provider name: $INPUT_PROVIDER and consumer label: $INPUT_PROVIDER_LABEL"
  if [ -n "$INPUT_PROVIDER" ]
  then
    provider_section="--consumer $INPUT_PROVIDER"
    if [ -n "$INPUT_PROVIDER_LABEL" ]
    then
      provider_section="provider_section --consumer-label $INPUT_PROVIDER_LABEL"
    fi
  fi
  echo "$provider_section"
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
  fi
  echo "$commander"
}

uri_setup() {
  uri=''
  if [ "$INPUT_WEBHOOK_TYPE" == "trigger_provider_job" ] || [ "$INPUT_WEBHOOK_TYPE" == "consumer_commit_status" ]
  then
    if [ "$INPUT_WEBHOOK_TYPE" == "trigger_provider_job" ]
    then
      uri="'https://api.github.com/repos/$INPUT_ORGANIZATION/$INPUT_REPOSITORY/dispatches'"
      echo "$uri"
    elif [ "$INPUT_WEBHOOK_TYPE" == "consumer_commit_status" ]
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
  validate_args

  echo "$PACT_CLI $EXECUTOR $command_to_execute $uri $broker_auth $provider_args $consumer_args $events_args"

#  docker run --rm pactfoundation/pact-cli:latest broker \
#                      "$COMMAND_TO_EXECUTE"  "$URI"\
#                      "$GITHUB_URI" \
#                      "$HEADERS" \
#                      "'Authorization: Bearer ${INPUT_GITHUB_PERSONAL_ACCESS_TOKEN}'" \
#                      "$REQUEST" \
#                      "$DATA" \
#                      "$PROVIDER_DETAILS"  "$CONSUMER_DETAILS" \
#                      "$EVENT_LIST" \
#                      "$WEBHOOK_DESCRIPTION" \
#                      "$INPUT_BROKER_BASE_URL" \
#                      "$BROKER_AUTHENTICATION" \
#                      "$TEAM_DETAILS"

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
create_webhook
#broker_auth="$(broker_auth_setup)"
#echo "$broker_auth"
#command_value=$(command_setup)
#echo "$command_value"
#uri_value="$(uri_setup)"
#echo "$uri_value"
#consumer="$(consumer_details)"
#echo "$consumer"
#provider="$(provider_details)"
#echo "$provider"
#events_to_add="$(webhook_events)"
#echo "$events_to_add"

