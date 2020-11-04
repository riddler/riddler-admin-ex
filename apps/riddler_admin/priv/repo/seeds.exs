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
  Agents
}

{:ok, identity} = Identities.register_identity(%{email: "foo@bar.com", password: "Asdfjkl;1234"})

account = Repo.insert!(%Accounts.Account{name: "Default", owner_identity_id: identity.id})

workspace =
  Repo.insert!(%Workspaces.Workspace{
    id: "wsp_SEED",
    name: "Default",
    key: "default",
    owner_identity_id: identity.id,
    account_id: account.id
  })

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

_condition =
  Repo.insert!(%Conditions.Condition{
    name: "true",
    key: "true",
    workspace_id: workspace.id,
    source: "true",
    instructions: [["lit", true]]
  })

_flag =
  Repo.insert!(%Flags.Flag{
    name: "Of Age",
    key: "of_age",
    type: "Variant",
    workspace_id: workspace.id,
    include_source: "age > 18",
    include_instructions: [["load", "age"], ["lit", 18], ["compare", "GT"]]
  })
