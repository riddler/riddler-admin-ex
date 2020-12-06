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
  Accounts,
  Agents,
  Conditions,
  ContentBlocks,
  Definitions,
  Elements,
  Environments,
  Flags,
  Identities,
  Previews,
  Repo,
  Workspaces
}

require Logger

# {:ok, identity} = Identities.register_identity(%{email: "foo@bar.com", password: "Asdfjkl;1234"})

# account = Repo.insert!(%Accounts.Account{name: "Default", owner_identity_id: identity.id})

# Logger.info("+++ Seeding Workspaces")

# workspace =
#   Repo.insert!(%Workspaces.Workspace{
#     id: "wsp_SEED",
#     name: "Default",
#     key: "default",
#     owner_identity_id: identity.id,
#     account_id: account.id
#   })

# Logger.info("+++ Seeding Environments and Agents")

# test_env =
#   Repo.insert!(%Environments.Environment{
#     id: "env_TESTSEED",
#     name: "Test",
#     key: "test",
#     workspace_id: workspace.id
#   })

# _test_agent =
#   Repo.insert!(%Agents.Agent{
#     name: "Test Agent",
#     key: "testagent",
#     api_key: "apikey_TESTSEED",
#     api_secret: "apisecret_TESTSEED",
#     environment_id: test_env.id
#   })

# Logger.info("+++ Seeding Conditions")

# _condition =
#   Repo.insert!(%Conditions.Condition{
#     name: "true",
#     key: "true",
#     workspace_id: workspace.id,
#     source: "true",
#     instructions: [["lit", true]]
#   })

# Logger.info("+++ Seeding Flags")

# # Static Assigner flag

# feature_flag =
#   Repo.insert!(%Flags.Flag{
#     name: "Static Flag",
#     key: "static_flag",
#     type: "Feature",
#     workspace_id: workspace.id,
#     enabled: true,
#     disabled_treatment: "disabled"
#   })

# feature_enabled_treatment =
#   Repo.insert!(%Flags.FlagTreatment{
#     key: "enabled",
#     flag_id: feature_flag.id
#   })

# _static_assigner =
#   Repo.insert!(%Flags.FlagAssigner{
#     flag_id: feature_flag.id,
#     rank: 1,
#     type: "Static",
#     enabled_treatment: feature_enabled_treatment
#   })

# # Rollout Assigner flag

# rollout_flag =
#   Repo.insert!(%Flags.Flag{
#     name: "Rollout Flag",
#     key: "rollout_flag",
#     type: "Feature",
#     workspace_id: workspace.id,
#     enabled: true,
#     disabled_treatment: "disabled"
#   })

# rollout_enabled_treatment =
#   Repo.insert!(%Flags.FlagTreatment{
#     key: "enabled",
#     flag_id: rollout_flag.id
#   })

# _rollout_assigner =
#   Repo.insert!(%Flags.FlagAssigner{
#     flag_id: rollout_flag.id,
#     rank: 1,
#     type: "Rollout",
#     enabled_treatment: rollout_enabled_treatment,
#     percentage: 50,
#     subject: "user_id"
#   })

# # Beers flag

# beers_flag =
#   Repo.insert!(%Flags.Flag{
#     name: "Beers",
#     key: "beers",
#     type: "Feature",
#     workspace_id: workspace.id,
#     enabled: true,
#     include_source: "age > 18",
#     include_instructions: [["load", "age"], ["lit", 21], ["compare", "GT"]],
#     disabled_treatment: "disabled"
#   })

# beers_enabled_treatment =
#   Repo.insert!(%Flags.FlagTreatment{
#     key: "enabled",
#     flag_id: beers_flag.id
#   })

# _static_assigner =
#   Repo.insert!(%Flags.FlagAssigner{
#     flag_id: beers_flag.id,
#     rank: 1,
#     type: "Static",
#     enabled_treatment: beers_enabled_treatment
#   })

# Logger.info("+++ Creating Previews (and PreviewContexts)")

# _of_age_context =
#   Repo.insert!(%Previews.PreviewContext{
#     workspace_id: workspace.id,
#     name: "Of Age",
#     data: %{age: 21}
#   })

# _beta_context =
#   Repo.insert!(%Previews.PreviewContext{
#     workspace_id: workspace.id,
#     name: "Beta",
#     data: %{is_beta: true}
#   })

# _preview =
#   Repo.insert!(%Previews.Preview{
#     workspace_id: workspace.id,
#     name: "Default Preview"
#   })

# Logger.info("+++ Creating Definition")

# {:ok, _definition} =
#   Definitions.create_definition(
#     %{
#       label: "Seed definition"
#     },
#     workspace.id
#   )

Logger.info("+++ Creating ContentBlocks")

welcome_message_cb =
  Repo.insert!(%ContentBlocks.ContentBlock{
    id: "cbl_WELCOME",
    workspace_id: "wsp_SEED",
    name: "Welcome Message",
    key: "welcome_message"
  })

_welcome_message_el =
  Repo.insert!(%Elements.Element{
    id: "el_WELCOME",
    type: "Text",
    content_block_id: welcome_message_cb.id,
    name: "Welcome Message",
    key: "welcome_message",
    text: "Welcome to this awesome sauce!"
  })
