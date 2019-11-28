defmodule RcCar.Router do
  use Plug.Router

  plug Plug.Static.IndexHtml, at: "/"
  plug Plug.Static, at: "/", from: "wwwroot"

  plug :match
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :dispatch

  put "/left" do
    IO.inspect(conn.params)
    send_resp(conn, 204, "OK")
  end

  put "/right" do
    IO.inspect(conn.params)
    send_resp(conn, 204, "OK")
  end
  
  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
