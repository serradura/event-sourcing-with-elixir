defmodule BankAPI.Accounts.AccountsTest do
  use BankAPI.Test.InMemoryEventStoreCase

  alias BankAPI.Repo
  alias BankAPI.Accounts
  alias BankAPI.Accounts.Projections.Account

  describe ".open_account()" do
    test "opens account with valid command" do
      params = %{
        "initial_balance" => 1_000
      }

      assert {:ok, %Account{current_balance: 1_000}} = Accounts.open_account(params)
    end

    test "does not dispatch command with invalid payload" do
      params = %{
        "initial_whatevs" => 1_000
      }

      assert {:error, :bad_command} = Accounts.open_account(params)
    end

    test "returns validation errors from dispatch" do
      params1 = %{
        "initial_balance" => "1_000"
      }

      params2 = %{
        "initial_balance" => -10
      }

      params3 = %{
        "initial_balance" => 0
      }

      assert {
              :error,
              :command_validation_failure,
              _cmd,
              ["Expected INTEGER, got STRING \"1_000\", at initial_balance"]
            } = Accounts.open_account(params1)

      assert {
              :error,
              :command_validation_failure,
              _cmd,
              ["Argument must be bigger than zero"]
            } = Accounts.open_account(params2)

      assert {
              :error,
              :command_validation_failure,
              _cmd,
              ["Argument must be bigger than zero"]
            } = Accounts.open_account(params3)
    end
  end

  describe ".get_account()" do
    test "gets stored accounts" do
      uuid = UUID.uuid4

      Repo.insert(%Account{current_balance: 2, uuid: uuid})

      assert {
              :ok,
              %Account{current_balance: 2, uuid: uuid}
             } = Accounts.get_account(uuid)
    end

    test "returns an error when not found" do
      uuid = "b9343867-78da-424a-9b49-068844b00000"

      assert {:error, :not_found} = Accounts.get_account(uuid)
    end

    test "returns an error when receive an invalid UUID" do
      uuid = "b9343867-78da-424a-9b49-068844b000"

      assert {:validation_error, %{}} = Accounts.get_account(uuid)
    end
  end
end
