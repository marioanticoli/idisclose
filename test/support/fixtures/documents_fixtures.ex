defmodule Idisclose.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Idisclose.Documents` context.
  """

  @doc """
  Generate a template.
  """
  def template_fixture(attrs \\ %{}) do
    {:ok, template} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> Idisclose.Documents.create_template()

    template
  end
end
