defmodule Idisclose.PieceTableFacadeTest do
  use Idisclose.DataCase

  alias Idisclose.PieceTableFacade.Impl, as: PieceTableFacade

  describe "load/2" do
    test "creates piece table from file" do
      table = PieceTableFacade.new!("test")

      Mox.expect(Idisclose.FileStorage.Mock, :file_read, fn _, _ ->
        content =
          table
          |> Map.from_struct()
          |> Jason.encode!()

        {:ok, content}
      end)

      assert {:ok, table} == PieceTableFacade.load("123", "abc")
    end

    test "returns error if cannot create" do
      expected = {:error, :enoent}

      Mox.expect(Idisclose.FileStorage.Mock, :file_read, fn _, _ ->
        expected
      end)

      assert expected == PieceTableFacade.load("abc", "123")
    end
  end

  describe "save/3" do
    test "save serialized piece table to file" do
      Mox.expect(Idisclose.FileStorage.Mock, :file_write, fn _, _, _ -> :ok end)
      Mox.expect(Idisclose.FileStorage.Mock, :dir?, fn _ -> true end)

      table = PieceTable.new!("test")
      assert {:ok, ^table} = PieceTableFacade.save(table, "aaa", "bbb")
    end

    test "save serialized piece table to file where dir does not exist" do
      Mox.expect(Idisclose.FileStorage.Mock, :file_write, fn _, _, _ -> :ok end)
      Mox.expect(Idisclose.FileStorage.Mock, :dir?, fn _ -> false end)
      Mox.expect(Idisclose.FileStorage.Mock, :mkdir, fn _ -> :ok end)

      table = PieceTable.new!("test")
      assert {:ok, ^table} = PieceTableFacade.save(table, "aaa", "bbb")
    end

    test "returns error if cannot save" do
      Mox.expect(Idisclose.FileStorage.Mock, :file_write, fn _, _, _ -> {:error, :eacces} end)
      Mox.expect(Idisclose.FileStorage.Mock, :dir?, fn _ -> true end)

      table = PieceTable.new!("test")
      assert {:error, ^table} = PieceTableFacade.save(table, "aaa", "bbb")
    end
  end

  describe "diff_string/3" do
    setup do
      table = PieceTable.new!("long(ish) text test")
      template = %{ins: "+++~s", del: "---~s", edit: "+-=~s"}

      %{table: table, template: template}
    end

    test "creates diff for insertion at start", %{table: table, template: template} do
      change = "my very "
      table = PieceTable.insert!(table, change, 0)
      updated_table = PieceTable.undo!(table)

      assert {updated_table, ["", "+++#{change}", "long(ish) text test"]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for insertion at end", %{table: table, template: template} do
      change = " the end of it"
      table = PieceTable.insert!(table, change, 19)
      updated_table = PieceTable.undo!(table)

      assert {updated_table, ["long(ish) text test", "+++#{change}", ""]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for insertion", %{table: table, template: template} do
      change = "'s new "
      table = PieceTable.insert!(table, change, 14)
      updated_table = PieceTable.undo!(table)

      assert {updated_table, ["long(ish) text", "+++#{change}", " test"]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for deletion at start", %{table: table, template: template} do
      table = PieceTable.delete!(table, 0, 10)
      updated_table = PieceTable.undo!(table)

      assert {updated_table, ["", "---long(ish) ", "text test"]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for deletion at end", %{table: table, template: template} do
      table = PieceTable.delete!(table, 14, 5)
      updated_table = PieceTable.undo!(table)

      assert {updated_table, ["long(ish) text", "--- test", ""]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for deletion", %{table: table, template: template} do
      table = PieceTable.delete!(table, 4, 5)
      updated_table = PieceTable.undo!(table)

      assert {updated_table, ["long", "---(ish)", " text test"]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for edit at start", %{table: table, template: template} do
      table = table |> PieceTable.delete!(0, 4) |> PieceTable.insert!("extra-short", 0)
      updated_table = table |> PieceTable.undo!() |> PieceTable.undo!()

      assert {updated_table, ["", "+-=extra-short", "(ish) text test"]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for edit at end", %{table: table, template: template} do
      table = table |> PieceTable.delete!(14, 5) |> PieceTable.insert!("!!!", 14)
      updated_table = table |> PieceTable.undo!() |> PieceTable.undo!()

      assert {updated_table, ["long(ish) text", "+-=!!!", ""]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for edit", %{table: table, template: template} do
      table = table |> PieceTable.delete!(4, 5) |> PieceTable.insert!("er", 4)
      updated_table = table |> PieceTable.undo!() |> PieceTable.undo!()

      assert {updated_table, ["long", "+-=er", " text test"]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for edit forward", %{table: table, template: template} do
      table = table |> PieceTable.delete!(4, 5) |> PieceTable.insert!("est-est-est-est", 4)
      updated_table = table |> PieceTable.undo!() |> PieceTable.undo!()

      assert {table, ["long", "+-=est-est-est-est", " text test"]} ==
               PieceTableFacade.diff_string(:next, updated_table, template)
    end

    test "created diff with undo then redo", %{table: table, template: template} do
      table =
        table
        |> PieceTable.insert!("!!!!", 19)
        |> PieceTable.delete!(4, 5)
        |> PieceTable.insert!("er", 4)

      updated_table1 = table |> PieceTable.undo!() |> PieceTable.undo!()

      assert {updated_table1, ["long", "+-=er", " text test!!!!"]} ==
               PieceTableFacade.diff_string(:prev, table, template)

      updated_table2 = updated_table1 |> PieceTable.undo!()

      assert {updated_table2, ["long(ish) text test", "+++!!!!", ""]} ==
               PieceTableFacade.diff_string(:prev, updated_table1, template)
    end

    test "returns original if no changes", %{table: table, template: template} do
      assert {table, table.result} == PieceTableFacade.diff_string(:prev, table, template)
      assert {table, table.result} == PieceTableFacade.diff_string(:next, table, template)
    end
  end

  # These functions below are actually already tested in the library
  describe "diff!/3" do
    test "works with 2 strings" do
      original = "nel mezo del camino di notra vit"
      result = "nel mezzo del cammin di nostra vita"

      assert %PieceTable{original: ^original, result: ^result} =
               PieceTableFacade.diff!(original, result, nil)
    end
  end

  describe "diff/3" do
    test "works with 2 strings" do
      original = "nel mezo del camino di notra vit"
      result = "nel mezzo del cammin di nostra vita"

      assert {:ok, %PieceTable{original: ^original, result: ^result}} =
               PieceTableFacade.diff(original, result, nil)
    end
  end

  describe "undo!/1" do
    test "un-does last change" do
      str = "my test"
      attrs = %{original: str, result: str}
      table = struct(PieceTable, attrs)
      pos = 0
      length = 3
      table = PieceTable.delete!(table, pos, length)

      updated_attrs =
        Map.merge(attrs, %{
          result: "my test",
          to_apply: [%PieceTable.Change{change: :del, text: "my ", position: 0}]
        })

      expected = struct(PieceTable, updated_attrs)

      assert expected == PieceTableFacade.undo!(table)
    end
  end

  describe "redo!/1" do
    test "redo changes" do
      str = "my test"
      attrs = %{original: str, result: str}
      table = struct(PieceTable, attrs)
      pos = 0
      length = 3
      table = PieceTable.delete!(table, pos, length)

      updated_attrs =
        Map.merge(attrs, %{
          result: "test",
          applied: [%PieceTable.Change{change: :del, text: "my ", position: 0}]
        })

      expected = struct(PieceTable, updated_attrs)

      {:ok, table} = PieceTable.undo(table)
      assert expected == PieceTableFacade.redo!(table)
    end
  end

  describe "get_text!/2" do
    test "it returns the edited text" do
      expected = "my test"

      Mox.expect(Idisclose.FileStorage.Mock, :file_read, fn _, _ ->
        result = expected |> PieceTable.new!() |> Map.from_struct() |> Jason.encode!()
        {:ok, result}
      end)

      assert expected == PieceTableFacade.get_text!("aaa", "bbb")
    end
  end
end
