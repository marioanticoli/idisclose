defmodule Idisclose.FileStorage.S3Test do
  use Idisclose.DataCase

  alias Idisclose.FileStorage.S3

  @test_port 8765
  setup do
    bypass = Bypass.open(port: @test_port)
    {:ok, bypass: bypass}
  end

  describe "file_read/2" do
    test "returns file content if file exists", %{bypass: bypass} do
      text = "my test"
      path = Ecto.UUID.generate()
      filename = Ecto.UUID.generate()

      Bypass.expect_once(bypass, "GET", "#{path}/#{filename}", fn conn ->
        Plug.Conn.resp(conn, 200, text)
      end)

      assert {:ok, text} == S3.file_read(path, filename)
    end

    test "returns error if cannot read file", %{bypass: bypass} do
      path = Ecto.UUID.generate()
      filename = Ecto.UUID.generate()

      Bypass.expect_once(bypass, "GET", "#{path}/#{filename}", fn conn ->
        Plug.Conn.resp(conn, 404, "")
      end)

      assert {:error, _} = S3.file_read(path, filename)
    end
  end

  describe "file_write/3" do
    test "returns ok if written", %{bypass: bypass} do
      text = "test"
      path = Ecto.UUID.generate()
      filename = Ecto.UUID.generate()

      Bypass.expect_once(bypass, "PUT", "#{path}/#{filename}", fn conn ->
        Plug.Conn.resp(conn, 201, text)
      end)

      Bypass.expect_once(bypass, "GET", "#{path}/#{filename}", fn conn ->
        Plug.Conn.resp(conn, 200, text)
      end)

      assert :ok == S3.file_write(path, filename, text)
      assert {:ok, text} == S3.file_read(path, filename)
    end

    test "returns error if cannot write", %{bypass: bypass} do
      path = Ecto.UUID.generate()
      filename = Ecto.UUID.generate()

      Bypass.expect_once(bypass, "PUT", "#{path}/#{filename}", fn conn ->
        Plug.Conn.resp(conn, 404, "")
      end)

      assert {:error, _} = S3.file_write(path, filename, "fail")
    end
  end

  describe "dir?/1" do
    test "returns true if dir exists", %{bypass: bypass} do
      dir = Ecto.UUID.generate()

      Bypass.expect_once(bypass, "GET", "#{dir}", fn conn ->
        Plug.Conn.resp(conn, 200, "")
      end)

      assert S3.dir?(dir)
    end

    test "returns false if dir doesn't exist", %{bypass: bypass} do
      dir = Ecto.UUID.generate()

      Bypass.expect_once(bypass, "GET", "#{dir}", fn conn ->
        Plug.Conn.resp(conn, 404, "")
      end)

      refute S3.dir?(dir)
    end
  end

  describe "mkdir/1" do
    test "creates dir", %{bypass: bypass} do
      path = Ecto.UUID.generate()

      Bypass.expect_once(bypass, "PUT", "#{path}", fn conn ->
        Plug.Conn.resp(conn, 201, "")
      end)

      assert :ok = S3.mkdir(path)
    end

    test "fails to create dir", %{bypass: bypass} do
      path = Ecto.UUID.generate()

      Bypass.expect_once(bypass, "PUT", "#{path}", fn conn ->
        Plug.Conn.resp(conn, 403, "")
      end)

      assert {:error, _} = S3.mkdir(path)
    end
  end
end
