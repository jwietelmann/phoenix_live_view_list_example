defmodule LiveViewListsWeb.ListLiveOptimized do
  use Phoenix.LiveView
  use Phoenix.HTML
  alias LiveViewLists.{Items, Item}

  defp ok(socket), do: {:ok, socket}
  defp noreply(socket), do: {:noreply, socket}

  def render(assigns) do
    ~L"""
    <div class="row">
      <div class="col">
        <h1>Optimized <small><%= link "<toggle>", to: "/" %></small></h1>

        <%= tag :span, phx_click: "create_random_item", class: "button" %>Create a random item</span>

        <table>
          <thead>
            <th>ID</th><th>Order</th><th></th>
          </thead>
          <%#

          1. The parent gets an attribute `phx-update="append"`.

          The parent needs an ID.
          The child needs an ID.
          When a child with an ID we already have shows up, it is replaced in its current location.
          When a child with a new ID shows up, it is appended at the end.

          2. Every item in the list is now a tuple: `{item, deleted?}`.

          When `deleted?` is true, this item should no longer be part of the list.

          3. Each child gets a corresponding `data-list-deleted` attribute.

          Since `phx-update="append"` means we can only replace children by ID or append them,
          we are going to have to write our own JavaScript to delete children.
          Set `data-list-deleted="true"` to flag a child for deletion.

          4. Each child gets a `data-list-order` attribute.

          Since `phx-update="append"` can only insert new children at the end of the list,
          we need a way to move those children from the end into their proper sort order.
          Set `data-list-order="42"` to set a child's sort order to 42.

          5. The parent gets an attribute `phx-hook="SortedList"`.

          The Phoenix hooks API can trigger JavaScript when this section of the LiveView updates.
          Our `SortedList` JavaScript hook deletes the children that need deleting and then sorts the rest.

          6. `@items` is configured to be a temporary assign.

          It is not persisted between renders.
          During any given render, `@items` only contains the items to be added, updated, or deleted.
          On the first render, it contains every item.
          On subsequent renders, it only contains one: The one to add/update/delete.
          Any previously-rendered child element will remain on the page until our hooks delete it.

          7. `[data-list-deleted="true"]` is styled as `display; none`.

          The LiveView may, from time to time, hear about an item, that is NOT already in its list, being deleted.
          In this case, that deleted element will be appended to the parent before our hooks delete it.
          A user should never see that, and this style makes sure of it.

          %>
          <tbody id="my-items-list" phx-update="append" phx-hook="SortedList">
            <%= for {%Item{id: id, order: order}, deleted?} <- @items do %>
              <%= tag :tr, id: "my-items-list-#{id}", data: [list: [order: order, deleted: deleted?]] %>
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

  defp set_items(socket, items) do
    assign(socket, items: Enum.map(items, & {&1, false}))
  end

  defp set_items(socket, items, [deleted?: true]) do
    assign(socket, items: Enum.map(items, & {&1, true}))
  end

  def mount(%{}, socket) do
    Items.subscribe()

    {:ok, set_items(socket, Items.list_all_items()), temporary_assigns: [:items]}
  end

  def handle_info({Items, action, item}, socket) when action in [:insert, :update] do
    {:noreply, set_items(socket, [item])}
  end

  def handle_info({Items, :delete, item}, socket) do
    {:noreply, set_items(socket, [item], deleted?: true)}
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
