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
      |> Router.dispatch(consistency: :strong)

    case dispatch_result do
      :ok -> get_account(account_uuid)
      err = {:error, _, _, _} -> err
    end
  end
  def open_account(_params), do: {:error, :bad_command}
end
