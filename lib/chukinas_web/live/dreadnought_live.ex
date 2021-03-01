alias Chukinas.Dreadnought.{MissionBuilder}

defmodule ChukinasWeb.DreadnoughtLive do
  use ChukinasWeb, :live_view
  alias ChukinasWeb.DreadnoughtView

  @impl true
  def mount(_params, _session, socket) do
   socket =
      socket
      |> assign(page_title: "Dreadnought")
      |> assign(mission: MissionBuilder.demo())
    {:ok, socket}
  end

  @impl true
  def handle_event("game_over", _, socket) do
    socket.assigns.mission
    |> Map.put(:state, :game_over)
    |> assign_mission(socket)
  end

  @impl true
  def handle_event("start_game", _, socket) do
    socket.assigns.mission
    |> Map.put(:state, :playing)
    |> assign_mission(socket)
  end

  defp assign_mission(mission, socket) do
    {:noreply, assign(socket, :mission, mission)}
  end
end
