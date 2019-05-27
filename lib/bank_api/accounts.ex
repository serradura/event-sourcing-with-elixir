defmodule BankAPI.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Changeset
  alias BankAPI.Repo
  alias BankAPI.Router
  alias BankAPI.Accounts.Commands.OpenAccount
  alias BankAPI.Accounts.Projections.Account

  def get_by_uuid!(uuid) do
    Account
    |> Ecto.Query.where(uuid: ^uuid)
    |> Ecto.Query.first
    |> Repo.one
  end

  def get_by_uuid(uuid) do
    with {:ok, [{:uuid, valid_uuid} | _]} <- UUID.info(uuid),
         account = %Account{} <- get_by_uuid!(valid_uuid) do
      {:ok, account}
    else
      {:error, message} -> {:error, :invalid_uuid, message}
      _ -> {:error, :not_found, "Account not found"}
    end
  end

  def get_account(uuid), do: Repo.get!(Account, uuid)

  def open_account(account_params) do
    changeset = account_opening_changeset(account_params)

    if changeset.valid? do
      account_uuid = UUID.uuid4()

      dispatch_result =
        %OpenAccount{
          initial_balance: changeset.changes.initial_balance,
          account_uuid: account_uuid
        }
        |> Router.dispatch(consistency: :strong)

      case get_account(account_uuid) do
        account = %Account{} -> {:ok, account}
        reply -> reply
      end
    else
      {:validation_error, changeset}
    end
  end

  defp account_opening_changeset(params) do
    {
      params,
      %{initial_balance: :integer}
    }
    |> Changeset.cast(params, [:initial_balance])
    |> Changeset.validate_required([:initial_balance])
    |> Changeset.validate_number(:initial_balance, greater_than: 0)
  end
end
