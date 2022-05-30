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

#command_to_execute=$(command_setup)
#uri="$(uri_setup)"
#broker_auth="$(broker_auth_setup)"
#consumer_args="$(consumer_details)"
#provider_args="$(provider_details)"
#events_args="$(webhook_events)"




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
    echo "Error - Action(input value) is $INPUT_ACTION,it must be either 'create' or 'update'"
    exit 1
    fi
  fi

  if [ "$INPUT_WEBHOOK_TYPE" != "trigger_provider_job" ]
  then
    if [ "$INPUT_WEBHOOK_TYPE" != "consumer_commit_status" ]
    then
    echo "Error - Webhook_type(input value) is $INPUT_WEBHOOK_TYPE , it must be either 'trigger_provider_job' or 'consumer_commit_status'"
    exit 1
    fi
  fi

  if [ -z "$(uri_setup)" ]
  then
    echo "Error - Webhook_type(input value) is $INPUT_WEBHOOK_TYPE , it must be either 'trigger_provider_job' or 'consumer_commit_status'"
    exit 1
  fi

  if [ -z "$(broker_auth_setup)" ]
  then
    echo "Error - either broker token or username+password has to be provided"
    exit 1
  fi

   if [ "$INPUT_WEBHOOK_TYPE" == "trigger_provider_job" ] && [ -z "$(provider_details)" ]
   then
     echo "Error - provider details has to be provided for 'trigger_provider_job' webhook"
   fi

   if [ "$INPUT_WEBHOOK_TYPE" == "consumer_commit_status" ] && [ -z "$(consumer_details)" ]
   then
     echo "Error - consumer details has to be provided for 'consumer_commit_status' webhook"
   fi

  if [ -z "$(webhook_events)" ]
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
  consumer_section=""
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
  if [ -n "$INPUT_PROVIDER" ]
  then
    provider_section="--provider $INPUT_PROVIDER"
    if [ -n "$INPUT_PROVIDER_LABEL" ]
    then
      provider_section="$provider_section --provider-label $INPUT_PROVIDER_LABEL"
    fi
  fi
  echo "$provider_section"
}

command_setup() {
  commander=""
  if [[ "$INPUT_ACTION" == "create" || "$INPUT_ACTION" == "update" ]]
  then
    if [ "$INPUT_ACTION" == "create" ]
    then
      commander="create-webhook"
    elif [ "$INPUT_ACTION" == "update" ]
    then
      commander="create-or-update-webhook"
    fi
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
    elif [ "$INPUT_WEBHOOK_TYPE" == "consumer_commit_status" ]
    then
      uri="'https://api.github.com/repos/$INPUT_ORGANIZATION/$INPUT_REPOSITORY/dispatches'"
    fi
  fi
  echo "$uri"
}

create_webhook() {
  command_to_execute=$(command_setup)
  uri=$(uri_setup)
  broker_auth="$(broker_auth_setup)"
  consumer_args="$(consumer_details)"
  provider_args="$(provider_details)"
  events_args="$(webhook_events)"


  echo "--------- $PACT_CLI $EXECUTOR $command_to_execute $uri --header 'Content-Type: application/json' 'Accept: application/vnd.github.everest-preview+json'
  $broker_auth $consumer_args $provider_args $events_args -------------"

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
echo "docker run --rm pactfoundation/pact-cli:latest broker $command_to_execute $uri"
echo "broker url: ${INPUT_BROKER_BASE_URL}"

  docker run --rm pactfoundation/pact-cli:latest broker $command_to_execute "'$uri'" \
                    --header 'Content-Type: application/json' 'Accept: application/vnd.github.everest-preview+json' \
                    "'Authorization: Bearer ${INPUT_GITHUB_PERSONAL_ACCESS_TOKEN}'" \
                    --request POST \
                    --data '{ "event_type": "pact_changed", "client_payload": { "pact_url": "${pactbroker.pactUrl}" } }' \
                    $provider_args \
                    $consumer_args \
                    $events_args \
                    --description "Pact content changed for pactflow-example-provider" \
                    --broker-base-url ${INPUT_BROKER_BASE_URL} \
                    --broker-token ${INPUT_BROKER_TOKEN}

#  docker run --rm pactfoundation/pact-cli:latest broker create-webhook 'https://api.github.com/repos/rajnavakotiikea/example-provider/dispatches' \
#                                                                        'https://api.github.com/repos/rajnavakotiikea/example-provider/dispatches'
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
  if [ -z "$INPUT_BROKER_TOKEN" ]
  then
    if [ -z "$INPUT_BROKER_USERNAME" ] || [ -z "$INPUT_BROKER_PASSWORD" ]
    then
      authentication=""
    else
      authentication="--broker-username $INPUT_BROKER_USERNAME --broker-password $INPUT_BROKER_PASSWORD"
    fi
  else
    authentication="--broker-token $INPUT_BROKER_TOKEN"
  fi
  echo "$authentication"
}

testing
validate_args
create_webhook
