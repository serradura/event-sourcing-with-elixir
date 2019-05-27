defmodule BankAPIWeb.AccountControllerTest do
  use BankAPIWeb.ConnCase

  @create_attrs %{
    initial_balance: 42_00
  }
  @invalid_attrs %{
    initial_balance: nil
  }

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "create account" do
    test "renders account when data is valid", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.account_path(conn, :create),
          account: @create_attrs
        )

      assert %{
               "uuid" => _uuid,
               "current_balance" => 4200
             } = json_response(conn, 201)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(
          conn,
          Routes.account_path(conn, :create),
          account: @invalid_attrs
        )

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "show account" do
    test "renders account when data is valid", %{conn: conn} do
      uuid = UUID.uuid4

      BankAPI.Repo.insert(%BankAPI.Accounts.Projections.Account{
        current_balance: 1,
        uuid: uuid
      })

      conn = get(conn, Routes.account_path(conn, :show, uuid))

      assert %{
               "uuid" => uuid,
               "current_balance" => 1
             } = json_response(conn, 200)["data"]
    end

    test "renders as bad request when uuid is invalid", %{conn: conn} do
      invalid_uuid = "598d1b3b"

      conn = get(conn, Routes.account_path(conn, :show, invalid_uuid))

      assert %{
               "error" => "Invalid argument; Not a valid UUID: 598d1b3b"
             } = json_response(conn, 400)["data"]
    end

    test "renders as not found when the account uuid was not found", %{conn: conn} do
      invalid_uuid = "598d1b3b-dcda-4058-a99b-09ef1efd95aa"

      conn = get(conn, Routes.account_path(conn, :show, invalid_uuid))

      assert %{
               "error" => "Account not found"
             } = json_response(conn, 404)["data"]
    end
  end
end
