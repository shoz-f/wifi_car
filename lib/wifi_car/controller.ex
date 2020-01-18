defmodule WifiCar.Controller do
  use Plug.Router
  
  alias WifiCar.Vehicle

  plug Plug.Static.IndexHtml, at: "/"
  plug Plug.Static, at: "/", from: :wifi_car

  plug :match
  plug Plug.Parsers, parsers: [:urlencoded]
  plug :dispatch

  put "/accelerator" do
  	speed = String.to_integer(conn.params["value"])
  	Vehicle.accelerator(speed)
    send_resp(conn, 204, "OK")
  end

  put "/steering" do
    dir = conn.params["value"]
  	Vehicle.steering(dir)
    send_resp(conn, 204, "OK")
  end
  
  match _ do
    IO.inspect(conn)
    send_resp(conn, 404, conn.request_path)
  end
end
