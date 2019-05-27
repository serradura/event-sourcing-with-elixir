defmodule BankAPI.Accounts.Commands.OpenAccount do
  @enforce_keys [:account_uuid]

  defstruct [:account_uuid, :initial_balance]
end
