# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     RiddlerAdmin.Repo.insert!(%RiddlerAdmin.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias RiddlerAdmin.{
  Repo,
  Identities,
  Accounts,
  Workspaces,
  Environments,
  Conditions,
  Flags,
  Agents,
  Definitions,
  Previews
}

require Logger

{:ok, identity} = Identities.register_identity(%{email: "foo@bar.com", password: "Asdfjkl;1234"})

account = Repo.insert!(%Accounts.Account{name: "Default", owner_identity_id: identity.id})

Logger.info("+++ Seeding Workspaces")

workspace =
  Repo.insert!(%Workspaces.Workspace{
    id: "wsp_SEED",
    name: "Default",
    key: "default",
    owner_identity_id: identity.id,
    account_id: account.id
  })

Logger.info("+++ Seeding Environments and Agents")

prod_env =
  Repo.insert!(%Environments.Environment{
    id: "env_PRODSEED",
    name: "Production",
    key: "prod",
    workspace_id: workspace.id
  })

_prod_agent =
  Repo.insert!(%Agents.Agent{
    name: "Prod Agent",
    key: "prodagent",
    api_key: "apikey_PRODSEED",
    api_secret: "apisecret_PRODSEED",
    environment_id: prod_env.id
  })

test_env =
  Repo.insert!(%Environments.Environment{
    id: "env_TESTSEED",
    name: "Test",
    key: "test",
    workspace_id: workspace.id
  })

_test_agent =
  Repo.insert!(%Agents.Agent{
    name: "Test Agent",
    key: "testagent",
    api_key: "apikey_TESTSEED",
    api_secret: "apisecret_TESTSEED",
    environment_id: test_env.id
  })

Logger.info("+++ Seeding Conditions")

_condition =
  Repo.insert!(%Conditions.Condition{
    name: "true",
    key: "true",
    workspace_id: workspace.id,
    source: "true",
    instructions: [["lit", true]]
  })

Logger.info("+++ Seeding Flags")

feature_flag =
  Repo.insert!(%Flags.Flag{
    name: "New Feature",
    key: "new_feature",
    type: "Treatment",
    workspace_id: workspace.id
  })

_enabled =
  Repo.insert!(%Flags.FlagTreatment{
    name: "Enabled",
    key: "enabled",
    flag_id: feature_flag.id,
    rank: 1,
    condition_source: "is_beta",
    condition_instructions: [["load", "is_beta"], ["to_bool"]]
  })

_disabled =
  Repo.insert!(%Flags.FlagTreatment{
    name: "Disabled",
    key: "disabled",
    flag_id: feature_flag.id,
    rank: 2
  })

beers_flag =
  Repo.insert!(%Flags.Flag{
    name: "Beers",
    key: "beers",
    type: "Treatment",
    workspace_id: workspace.id,
    include_source: "age > 18",
    include_instructions: [["load", "age"], ["lit", 18], ["compare", "GT"]]
  })

_enabled =
  Repo.insert!(%Flags.FlagTreatment{
    name: "Enabled",
    key: "enabled",
    flag_id: beers_flag.id,
    rank: 1,
    condition_source: "is_beta",
    condition_instructions: [["load", "is_beta"], ["to_bool"]]
  })

_disabled =
  Repo.insert!(%Flags.FlagTreatment{
    name: "Disabled",
    key: "disabled",
    flag_id: beers_flag.id,
    rank: 2
  })

# rollout_flag =
#   Repo.insert!(%Flags.Flag{
#     name: "Rollout",
#     key: "rollout",
#     type: "Percentage",
#     workspace_id: workspace.id,
#   })

# _enabled =
#   Repo.insert!(%Flags.FlagTreatment{
#     name: "Enabled",
#     key: "enabled",
#     flag_id: feature_flag.id,
#     rank: 1,
#     percentage: 0.1
#   })

# _disabled =
#   Repo.insert!(%Flags.FlagTreatment{
#     name: "Disabled",
#     key: "disabled",
#     flag_id: feature_flag.id,
#     rank: 2,
#     percentage: 0.9
#   })

Logger.info("+++ Creating Previews (and PreviewContexts)")

_of_age_context =
  Repo.insert!(%Previews.PreviewContext{
    workspace_id: workspace.id,
    name: "Of Age",
    data: %{age: 21}
  })

_beta_context =
  Repo.insert!(%Previews.PreviewContext{
    workspace_id: workspace.id,
    name: "Beta",
    data: %{is_beta: true}
  })

_preview =
  Repo.insert!(%Previews.Preview{
    workspace_id: workspace.id,
    name: "Default Preview"
  })

Logger.info("+++ Creating Definition")

{:ok, _definition} =
  Definitions.create_definition(
    %{
      label: "Seed definition"
    },
    workspace.id
  )
