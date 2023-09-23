defmodule Idisclose.FileStorageTest do
  use Idisclose.DataCase

  alias Idisclose.FileStorage.Local, as: FS

  describe "file_read/2" do
    test "returns file content if file exists" do
      text = "my test"
      path = Ecto.UUID.generate()
      tmp_dir = System.tmp_dir!() |> Path.join(path)
      filename = Ecto.UUID.generate()

      File.mkdir(tmp_dir)

      tmp_dir
      |> Path.join(filename)
      |> File.write!(text)

      assert {:ok, text} == FS.file_read(path, filename)
    end

    test "returns error if cannot read file" do
      assert {:error, _} = FS.file_read(Ecto.UUID.generate(), Ecto.UUID.generate())
    end
  end

  describe "file_write/3" do
    test "returns ok if written" do
      content = "test"
      path = Ecto.UUID.generate()
      filename = Ecto.UUID.generate()

      System.tmp_dir!()
      |> Path.join(path)
      |> File.mkdir()

      assert :ok == FS.file_write(path, filename, content)
      assert {:ok, content} == FS.file_read(path, filename)
    end

    test "returns error if cannot write" do
      path = System.tmp_dir!() |> Path.join(Ecto.UUID.generate())

      assert {:error, _} = FS.file_write(path, Ecto.UUID.generate(), "fail")
    end
  end

  describe "dir?/1" do
    test "returns true if dir exists" do
      dir = Ecto.UUID.generate()

      System.tmp_dir!()
      |> Path.join(dir)
      |> File.mkdir()

      assert FS.dir?(dir)
    end

    test "returns false if dir doesn't exist" do
      refute Ecto.UUID.generate() |> FS.dir?()
    end
  end

  describe "mkdir/1" do
    test "creates dir" do
      assert :ok = Ecto.UUID.generate() |> FS.mkdir()
    end

    test "fails to create dir" do
      assert {:error, _} = Ecto.UUID.generate() |> Path.join("/doesnt_exist") |> FS.mkdir()
    end
  end
end
