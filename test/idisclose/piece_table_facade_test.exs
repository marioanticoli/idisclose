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
      change = "my "
      table = PieceTable.insert!(table, change, 0)
      updated_table = PieceTable.undo!(table)

      assert {updated_table, ["", "+++#{change}", "long(ish) text test"]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for insertion at end", %{table: table, template: template} do
      change = " the end"
      table = PieceTable.insert!(table, change, 19)
      updated_table = PieceTable.undo!(table)

      assert {updated_table, ["long(ish) text test", "+++#{change}", ""]} ==
               PieceTableFacade.diff_string(:prev, table, template)
    end

    test "creates diff for insertion", %{table: table, template: template} do
      change = "'s"
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
      table = table |> PieceTable.delete!(0, 4) |> PieceTable.insert!("short", 0)
      updated_table = table |> PieceTable.undo!() |> PieceTable.undo!()

      assert {updated_table, ["", "+-=short", "(ish) text test"]} ==
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
end
