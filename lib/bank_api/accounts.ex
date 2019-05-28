defmodule BankAPI.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias BankAPI.Repo
  alias BankAPI.Router
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Projections.Account

  def get_account(uuid) do
    with {:ok, _} <- UUID.info(uuid),
         account = %Account{} <- Repo.get(Account, uuid) do
      {:ok, account}
    else
      nil -> {:error, :not_found}
      {:error, _} -> {:validation_error, %{}}
    end
  end

  def open_account(%{"initial_balance" => initial_balance}) do
    account_uuid = UUID.uuid4()

    dispatch_result =
      %OpenAccount{
        account_uuid: account_uuid,
        initial_balance: initial_balance
      }
      |> Router.dispatch()

    case dispatch_result do
      :ok ->
        {:ok, %Account{
          uuid: account_uuid,
          current_balance: initial_balance
        }}
      err = {:error, _, _, _} -> err
    end
  end
  def open_account(_params), do: {:error, :bad_command}
end
