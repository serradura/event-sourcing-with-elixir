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

  def show(conn, %{"id" => id}) do
    case Accounts.get_by_uuid(id) do
      {:ok, account} ->
        conn
        |> render("show.json", account: account)
      {:error, :invalid_uuid, message} ->
        conn
        |> render_error_as_json(:bad_request, message)
      {:error, :not_found, message} ->
        conn
        |> render_error_as_json(:not_found, message)
    end
  end

  defp render_error_as_json(conn, status, message) do
    conn
    |> put_status(status)
    |> json(%{data: %{error: message}})
  end
end
