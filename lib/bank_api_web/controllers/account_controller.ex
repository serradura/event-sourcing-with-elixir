defmodule BankAPIWeb.AccountController do
  use BankAPIWeb, :controller

  alias BankAPI.Accounts
  alias BankAPI.Accounts.Projections.Account

  action_fallback BankAPIWeb.FallbackController

  def create(conn, %{"account" => account_params}) do
    with {:ok, %Account{} = account} <- Accounts.open_account(account_params) do
      conn
      |> put_status(:created)
      |> render("show.json", account: account)
    end
  end
end
