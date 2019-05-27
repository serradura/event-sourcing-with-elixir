defmodule BankAPIWeb.AccountView do
  use BankAPIWeb, :view
  alias BankAPIWeb.AccountView

  def render("show.json", %{account: account}) do
    %{data: render_one(account, AccountView, "account.json")}
  end

  def render("account.json", %{account: account}) do
    %{
      uuid: account.uuid,
      current_balance: account.current_balance
    }
  end
end
