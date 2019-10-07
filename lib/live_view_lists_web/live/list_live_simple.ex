defmodule LiveViewListsWeb.ListLiveSimple do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias LiveViewLists.{Items, Item}

  defp ok(socket), do: {:ok, socket}
  defp noreply(socket), do: {:noreply, socket}

  def render(assigns) do
    ~L"""
    <div class="row">
      <div class="col">
        <h1>Unoptimized <small><%= link "<toggle>", to: "/optimized" %></small></h1>

        <%= tag :span, phx_click: "create_random_item", class: "button" %>Create a random item</span>

        <table>
          <thead>
            <th>ID</th><th>Order</th><th></th>
          </thead>
          <tbody>
            <%= for %Item{id: id, order: order} <- @items do %>
              <tr>
                <td><%= id %></td>
                <td><%= order %></td>
                <td>
                  <%= tag :span, to: "#", phx_click: "decrement_item_order", phx_value_id: id, class: "button" %>-1</span>
                  <%= tag :span, phx_click: "increment_item_order", phx_value_id: id, class: "button" %>+1</span>
                  <%= tag :span, to: "#", phx_click: "delete_item", phx_value_id: id, class: "button" %>Del</span>
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>

      <div class="col">
        <h1>Diff Debug</h1>
        <pre><code id="diff" phx-update="ignore">Waiting for update...</code></pre>
      </div>
    </div>
    """
  end

  defp split_items_list(socket, item) do
    socket.assigns.items
    |> Enum.split_while(& &1.id !== item.id)
    |> case do
      {head_items, [_ | tail_items]} -> {head_items, tail_items}
      {head_items, tail_items} -> {head_items, tail_items}
    end
  end

  defp set_items(socket, items) do
    assign(socket, items: Enum.sort_by(items, & &1.order))
  end

  defp update_item(socket, item) do
    {head_items, tail_items} = split_items_list(socket, item)

    set_items(socket, head_items ++ [item | tail_items])
  end

  defp delete_item(socket, item) do
    {head_items, tail_items} = split_items_list(socket, item)

    set_items(socket, head_items ++ tail_items)
  end

  def mount(%{}, socket) do
    Items.subscribe()

    {:ok, set_items(socket, Items.list_all_items())}
  end

  def handle_info({Items, action, item}, socket) when action in [:insert, :update] do
    {:noreply, update_item(socket, item)}
  end

  def handle_info({Items, :delete, item}, socket) do
    {:noreply, delete_item(socket, item)}
  end

  def handle_event("create_random_item", _, socket) do
    Items.create_random_item()

    {:noreply, socket}
  end

  def handle_event("delete_item", %{"id" => id}, socket) do
    id
    |> Items.get_item!()
    |> Items.delete_item()

    {:noreply, socket}
  end

  def handle_event("increment_item_order", %{"id" => id}, socket) do
    id
    |> Items.get_item!()
    |> Items.increment_item_order()

    {:noreply, socket}
  end

  def handle_event("decrement_item_order", %{"id" => id}, socket) do
    id
    |> Items.get_item!()
    |> Items.decrement_item_order()

    {:noreply, socket}
  end
end
