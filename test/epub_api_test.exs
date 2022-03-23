defmodule EpubApiTest do
  use ExUnit.Case
  use Plug.Test

  describe "GET /book?isbn=<isbn>" do
    test "retuns partial content status" do
      response =
        :get |> conn("/book?isbn=123") |> EpubApi.call([])

      assert response.status  == 206
    end
  end

  describe "HEAD /book?isbn=<isbn>" do
    test "retuns partial content status" do
      response =
        :head |> conn("/book?isbn=123", %{}) |> EpubApi.call([])

      assert response.status  == 200
    end
  end

  describe "OPTIONS /book?isbn=<isbn>" do
    test "retuns headers when a HEAD request is made" do
      response =
        :options |> conn("/book", %{}) |> EpubApi.call([])

      assert response.status  == 204
    end
  end
end
