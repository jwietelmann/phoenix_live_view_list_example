defmodule LiveViewLists.Item do
  alias LiveViewLists.Item
  import Ecto.Changeset
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "items" do
    field(:order, :integer)

    timestamps()
  end

  def changeset(%Item{} = item, params \\ %{}) do
    item
    |> cast(params, [:order])
    |> validate_required([:order])
  end
end

defmodule LiveViewLists.Items do
  import Ecto.{Query}, warn: false
  alias LiveViewLists.Repo
  alias LiveViewLists.Item

  defp broadcast({:ok, item} = result, action) do
    Phoenix.PubSub.broadcast(LiveViewLists.PubSub, "items", {__MODULE__, action, item})
  end

  defp broadcast(result), do: result

  def subscribe() do
    Phoenix.PubSub.subscribe(LiveViewLists.PubSub, "items")
  end

  def get_item!(id) do
    Repo.get!(Item, id)
  end

  def list_all_items() do
    Item
    |> order_by([item], item.order)
    |> Repo.all()
  end

  def create_item(%{} = params) do
    %Item{}
    |> Item.changeset(params)
    |> Repo.insert()
    |> broadcast(:insert)
  end

  def update_item(%Item{} = item, %{} = params) do
    item
    |> Item.changeset(params)
    |> Repo.update()
    |> broadcast(:update)
  end

  def create_random_item() do
    create_item(%{order: Enum.random(1..100)})
  end

  def delete_item(%Item{} = item) do
    item
    |> Repo.delete()
    |> broadcast(:delete)
  end

  def increment_item_order(%Item{} = item), do: add_order(item, 1)

  def decrement_item_order(%Item{} = item), do: add_order(item, -1)

  defp add_order(%{order: order} = item, amount) when is_integer(amount) do
    update_item(item, %{order: order + amount})
  end
end
