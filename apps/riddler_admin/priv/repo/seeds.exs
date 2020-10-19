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
alias RiddlerAdmin.{Repo, Identities, Accounts, Workspaces}

{:ok, identity} = Identities.register_identity(%{email: "foo@bar.com", password: "Zaq1Xsw2Cde3"})

account = Repo.insert!(%Accounts.Account{name: "Default", owner_identity_id: identity.id})

_workspace =
  Repo.insert!(%Workspaces.Workspace{
    name: "Default",
    owner_identity_id: identity.id,
    account_id: account.id
  })
