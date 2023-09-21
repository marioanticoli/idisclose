defmodule IdiscloseWeb.SignalingChannelTest do
  use IdiscloseWeb.ChannelCase

  setup do
    {:ok, _, socket} =
      IdiscloseWeb.UserSocket
      |> socket("user_id", %{user: "test_user"})
      |> subscribe_and_join(IdiscloseWeb.SignalingChannel, "signaling:lobby")

    %{socket: socket}
  end

  test "offer replies with status ok", %{socket: socket} do
    payload = %{"hello" => "there"}
    push(socket, "offer", payload)
    assert_broadcast("offer", ^payload)
  end

  test "answer replies with status ok", %{socket: socket} do
    payload = %{"hello" => "there"}
    push(socket, "answer", payload)
    assert_broadcast("answer", ^payload)
  end

  test "candidate replies with status ok", %{socket: socket} do
    payload = %{"hello" => "there"}
    push(socket, "ice_candidate", payload)
    assert_broadcast("ice_candidate", ^payload)
  end
end
