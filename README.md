# Pact command execution

Github Action for trigger a workflow from another workflow. The action then waits for a response.

**When would you use it?**

When deploying an app you may need to deploy additional services, this Github Action helps with that.


## Arguments

| Argument Name                                  | Required | Default | Description                                                                        | Allowed                                              |
|------------------------------------------------|----------|---------|------------------------------------------------------------------------------------|------------------------------------------------------|
| `action`                                       | True     | N/A     | Webhook action                                                                     | **create**, **update**                               |
| `webhook_type`                                 | True     | N/A     | Type of webhook                                                                    | **trigger_provider_job**, **consumer_commit_status** |
| `organization`                                 | True     | N/A     | Name of the git organization                                                       |                                                      |
| `repository`                                   | True     | N/A     | Name of the git repository                                                         |                                                      |
| `github_personal_access_token`                 | True     | N/A     | Github access token                                                                |                                                      |
| `description`                                  | True     | N/A     | Webhook description                                                                |                                                      |
| `broker_base_url`                              | True     | N/A     | Pact_Broker/Pact_Flow  base url                                                    |                                                      |
| `broker_username`                              | False    | N/A     | Pact Broker basic auth username                                                    |                                                      |
| `broker_password`                              | False    | N/A     | Pact Broker basic auth password                                                    |                                                      |
| `broker_token`                                 | False    | N/A     | Pact Broker bearer token                                                           |                                                      |
| `user`                                         | False    | N/A     | Webhook basic auth username and password eg. username:password                     |                                                      |
| `consumer`                                     | False    | N/A     | Consumer name                                                                      |                                                      |
| `consumer_label`                               | False    | N/A     | Consumer label, mutually exclusive with consumer name                              |                                                      |
| `provider`                                     | False    | N/A     | Provider name                                                                      |                                                      |
| `provider_label`                               | False    | N/A     | Provider label, mutually exclusive with provider name                              |                                                      |
| `contract_content_changed`                     | False    | false   | Trigger this webhook when the pact content changes                                 | **true**, **false**                                  |
| `no_contract_content_changed`                  | False    | false   | Trigger this webhook when the no pact content changes                              | **true**, **false**                                  |
| `contract_published`                           | False    | false   | Trigger this webhook when a pact is published                                      | **true**, **false**                                  |
| `no_contract_published`                        | False    | false   | Trigger this webhook when no contract published                                    | **true**, **false**                                  |
| `provider_verification_published`              | False    | false   | Trigger this webhook when a provider verification result is published              | **true**, **false**                                  |
| `no_provider_verification_published`           | False    | false   | Trigger this webhook when no provider verification result published                | **true**, **false**                                  |
| `provider_verification_failed`                 | False    | false   | Trigger this webhook when a failed provider verification result is published       | **true**, **false**                                  |
| `no_provider_verification_failed`              | False    | false   | Trigger this webhook when no failed provider verification result published         | **true**, **false**                                  |
| `provider_verification_succeeded`              | False    | false   | Trigger this webhook when a successful provider verification result is published   | **true**, **false**                                  |
| `no_provider_verification_succeeded`           | False    | false   | Trigger this webhook when no successful provider verification result published     | **true**, **false**                                  |
| `contract_requiring_verification_published`    | False    | false   | Trigger this webhook when a contract is published that requires verification       | **true**, **false**                                  |
| `no_contract_requiring_verification_published` | False    | false   | Trigger this webhook when no contract is published that requires verification      | **true**, **false**                                  |
| `team_uuid`                                    | False    | N/A     | UUID of the Pactflow team to which the webhook should be assigned (Pact flow only) | Only for pact flow                                   |

## Example

### Create 'repository_dispatch' webhook to trigger provider webhook

```yaml
- uses: rajnavakotiikea/pact-command-execution@v1.0.2
  with:
    action: create
    webhook_type: trigger_provider_job
    description: provider job webhook for pactflow-example-provider
    organization: org_name
    repository: example-provider
    github_personal_access_token : git_access_token
    broker_base_url: https://example.pactflow.io
    broker_token: pact_broker_token
    consumer: pactflow-example-consumer
    provider: pactflow-example-provider
    contract_content_changed: true
    contract_published: true
```

### Create 'git commit status' webhook to receive verification status on consumer side

```yaml
- uses: rajnavakotiikea/pact-command-execution@v1.0.2
  with:
    action: create
    webhook_type: consumer_commit_status
    description: git commit status webhook for pactflow-example-consumer
    organization: org_name
    repository: example-provider
    github_personal_access_token : git_access_token
    broker_base_url: https://example.pactflow.io
    broker_token: pact_broker_token
    consumer: pactflow-example-consumer
    provider: pactflow-example-provider
    contract_content_changed: true
    contract_published: true
```

