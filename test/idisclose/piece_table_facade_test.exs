defmodule Idisclose.PieceTableFacadeTest do
  use Idisclose.DataCase

  alias Idisclose.PieceTableFacade

  describe "load/2" do
    test "creates piece table from file" do
      assert 1 == 0
    end

    test "returns error if cannot create" do
      assert 1 == 0
    end
  end

  describe "save/3" do
    test "save serialized piece table to file" do
      assert 1 == 0
    end

    test "returns error if cannot save" do
      assert 1 == 0
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

      updated_table3 = updated_table2 |> PieceTable.redo!()

      # assert {updated_table3, ["long(ish) text test", "+++!!!!", ""]} ==
      # PieceTableFacade.diff_string(:next, updated_table2, template)

      updated_table4 = updated_table3 |> PieceTable.redo!() |> PieceTable.redo!()

      assert {updated_table4, []} == PieceTableFacade.diff_string(:next, updated_table3, template)
    end

    test "returns original if no changes", %{table: table, template: template} do
      assert {table, table.result} == PieceTableFacade.diff_string(:prev, table, template)
      assert {table, table.result} == PieceTableFacade.diff_string(:next, table, template)
    end
  end
end
