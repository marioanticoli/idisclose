defmodule IdiscloseWeb.VideoChatController do
  use IdiscloseWeb, :controller

  def video(conn, _params) do
    render(conn, :video, layout: false)
  end
end
