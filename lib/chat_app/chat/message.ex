defmodule ChatApp.Chat.Message do
    use Ecto.Schema
    import Ecto.Changeset
  
    schema "messages" do
      field :content, :string
      field :timestamp, :naive_datetime
      field :pid, :string
  
      timestamps()
    end
  
    def changeset(message, attrs) do
      message
      |> cast(attrs, [:content, :timestamp, :pid])
      |> validate_required([:content, :timestamp, :pid])
    end
  end
  