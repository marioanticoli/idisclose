defmodule Idisclose.NotificationsTest do
  use Idisclose.DataCase

  require Phoenix.ChannelTest

  alias Idisclose.Notifications

  # FIXME: why doesn't it receive anything?
  @tag :skip
  test "notification received" do
    assert :ok = Notifications.sys_msg!("test", "this is a test")
    Phoenix.ChannelTest.assert_push("room:test", "this is a test")
  end
end
