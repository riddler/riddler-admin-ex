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

alias RiddlerAdmin.Repo
alias RiddlerAdmin.Accounts.User

_sysadmin_user =
  Repo.insert!(%User{
    email: "sys@ra.com",
    sysadmin: true,
    confirmed_at: DateTime.utc_now()
  })

_user =
  Repo.insert!(%User{
    email: "a@b.com",
    confirmed_at: DateTime.utc_now()
  })
