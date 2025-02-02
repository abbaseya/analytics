defmodule Plausible.Goal do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:domain, :event_name, :page_path]}
  schema "goals" do
    field :domain, :string
    field :event_name, :string
    field :page_path, :string

    timestamps()
  end

  def changeset(goal, attrs \\ %{}) do
    goal
    |> cast(attrs, [:domain, :event_name, :page_path])
    |> validate_required([:domain])
    |> validate_event_name_and_page_path()
  end

  defp validate_event_name_and_page_path(changeset) do
    if validate_page_path(changeset) || validate_event_name(changeset) do
      changeset
    else
      changeset
      |> add_error(:event_name, "this field is required and cannot be blank")
      |> add_error(:page_path, "this field is required and must start with a /")
    end
  end

  defp validate_page_path(changeset) do
    value = get_field(changeset, :page_path)
    value && String.match?(value, ~r/^\/.*/)
  end

  defp validate_event_name(changeset) do
    value = get_field(changeset, :event_name)
    value && String.match?(value, ~r/^.+/)
  end
end
