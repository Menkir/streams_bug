defmodule StreamsBugWeb.Stream do
  use StreamsBugWeb, :live_view

  @default [
    %{
      message: "foo",
      id: "1"
    },
    %{
      message: "baz",
      id: "2"
    },
    %{
      message: "bar",
      id: "3"
    },
  ]

  def render(assigns) do
    ~H"""
    <div id="foo" phx-update="replace" class="absolute inset-0 w-screen h-screen flex flex-col justify-center items-center">
      <button id="my-buttton" phx-click={@event} class="order-0 bg-gray-500 text-white rounded-md p-3"> <%= @event %></button>
      <div class={"order-#{index}"} :for={{{dom_id, row}, index} <- Enum.with_index(@streams.rows, 1)} id={dom_id}> <%= row.message%> </div>
    </div>
    """
  end

  def mount(_, _, socket) do
    {:ok,
    socket
    |> stream(:rows, @default)
    |> assign(:event, "collapse")
    }
  end


  def handle_event("collapse", _, socket) do

    {:noreply,
      Enum.reduce(@default, socket, fn row, sock ->
        stream_delete(sock, :rows, row)
      end)
      |> assign(:event, "expand")
      |> tap(& IO.inspect(&1.assigns.streams.rows))
    }
  end

  def handle_event("expand", _, socket) do
    {:noreply,
      Enum.reduce(@default |> Enum.with_index(), socket, fn {row, index}, sock ->
        stream_insert(sock, :rows, row, at: index)
      end)
      |> assign(:event, "collapse")
      |> tap(& IO.inspect(&1.assigns.streams.rows))
    }
  end

end
