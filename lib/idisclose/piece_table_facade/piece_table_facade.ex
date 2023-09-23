defmodule Idisclose.PieceTableFacade do
  @moduledoc """
  Facade to simplify intereaction with the PieceTable library
  """

  @type template :: %{
          ins: String.t(),
          del: String.t(),
          edit: String.t()
        }

  @callback new!(String.t()) :: PieceTable.t()
  @callback diff!(PieceTable.Differ.original_input(), String.t(), any()) :: PieceTable.t()
  @callback diff(PieceTable.Differ.original_input(), String.t(), any()) ::
              {:ok, PieceTable.t()} | {:error, atom()}
  @callback undo!(PieceTable.t()) :: PieceTable.t()
  @callback redo!(PieceTable.t()) :: PieceTable.t()
  @callback load(String.t(), String.t()) :: {:ok, PieceTable.t()} | {:error, any()}
  @callback get_text!(String.t(), String.t()) :: binary()
  @callback save(PieceTable.t(), String.t(), String.t()) ::
              {:ok, PieceTable.t()} | {:error, PieceTable.t()}
  @callback diff_string(atom(), PieceTable.t(), template()) :: {PieceTable.t(), String.t()}
end
