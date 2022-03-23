defmodule EpubApi do
  @moduledoc """
  Endpoints :
  - /book?isbn=<isbn> : get a book (GET)

  """

  @doc """
  """
  use Plug.Router

  plug(CORSPlug, origin: "http://localhost")
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Jason,
    length: 20_000_000
  )

  head "/book" do
    head_response(conn)
  end

  get "/book" do
    get_response("123", conn)
  end

  match _ do
    send_resp(conn, 404, "Not found")
  end

  defp head_response(conn) do
    conn
    |> Plug.Conn.put_resp_header("accept-ranges", "bytes")
    |> Plug.Conn.put_resp_header("access-control-allow-methods", "GET, HEAD, OPTIONS")
    |> Plug.Conn.put_resp_header("access-control-expose-headers", "Content-Length, Content-Range")
    |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
    |> Plug.Conn.send_resp(200, "OK")
  end

  defp get_response(isbn, conn) do
    file_path = "books/#{isbn}.epub"
    {:ok, stats} = File.stat(file_path)

    filesize = stats.size

    [range_start, range_end] =
      if Enum.empty?(Plug.Conn.get_req_header(conn, "range")) do
        [0, filesize - 1]
      else
        [rn] = Plug.Conn.get_req_header(conn, "range")

        res = Regex.run(~r/bytes=([0-9]+)-([0-9]+)?/, rn)
        default_end = Integer.to_string(filesize - 2)

        {range_start, _} = res |> Enum.at(1) |> Integer.parse()
        {range_end, _} = res |> Enum.at(2, default_end) |> Integer.parse()

        [range_start, range_end]
      end

    content_length = range_end - range_start + 2

    conn
    |> Plug.Conn.put_resp_content_type("application/epub+zip")
    |> Plug.Conn.put_resp_header("access-control-allow-origin", "*")
    |> Plug.Conn.put_resp_header("content-length", Integer.to_string(content_length))
    |> Plug.Conn.put_resp_header("accept-ranges", "bytes")
    |> Plug.Conn.put_resp_header("content-disposition", ~s(inline; isbn="#{isbn}"))
    |> Plug.Conn.put_resp_header("content-range", "bytes #{range_start}-#{range_end}/#{filesize}")
    |> Plug.Conn.send_file(206, file_path, range_start, content_length)
  end
end
