defmodule ChukinasWeb.DreadnoughtLive do

  use ChukinasWeb, :live_view
  alias Chukinas.Sessions
  alias Chukinas.Dreadnought.Mission

  # *** *******************************
  # *** CALLBACKS (MOUNT/PARAMS)

  @impl true
  def mount(_params, session, socket) do
    socket = assign_uuid_and_mission(socket, session)
    {:ok, socket, layout: {ChukinasWeb.LayoutView, "ocean.html"}}
  end

  @spec assign_uuid_and_mission(Phoenix.LiveView.Socket.t, map) :: Phoenix.LiveView.Socket.t
  def assign_uuid_and_mission(socket, session) do
    IOP.inspect self()
    uuid = Map.fetch!(session, "uuid")
    if socket.connected? do
      Sessions.register_uuid(uuid)
      socket
      |> assign(uuid: uuid)
      |> assign(mission: Sessions.get_mission_from_player_uuid(uuid))
    else
      socket
      |> assign(uuid: uuid)
      |> assign(mission: nil)
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    live_action = socket.assigns.live_action
    cond do
      live_action == :gallery ->
        :ok
      mission_in_progress?(socket) ->
        path = Routes.dreadnought_play_path(socket, :index)
        send self(), {:push_redirect, path}
      true ->
        :ok
    end
    socket =
      socket
      |> standard_assigns
      |> assign_header
    {:noreply, socket}
  end

  # *** *******************************
  # *** CALLBACKS (EVENTS)

  #@impl true
  #def handle_event("toggle_show_markers", _, socket) do
  #  socket =
  #    socket
  #    |> assign(show_markers?: !socket.assigns[:show_markers?])
  #  {:noreply, socket}
  #end

  # *** *******************************
  # *** CALLBACKS (INFO)

  @impl true
  def handle_info({:push_patch, path}, socket) do
    socket =
      socket
      |> push_patch(to: path)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:push_redirect, path}, socket) do
    socket =
      socket
      |> push_redirect(to: path)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:update_assigns, new_assigns}, socket) do
    socket =
      socket
      |> assign(new_assigns)
    {:noreply, socket}
  end

  # TODO does the user struct still need the room name, etc?
  @impl true
  def handle_info({:update_room, mission}, socket) do
    socket =
      if mission_in_progress?(mission) do
        path = Routes.dreadnought_play_path(socket, :index)
        Phoenix.LiveView.push_redirect(socket, to: path)
      else
        socket
        |> assign(mission: mission)
        |> assign_header
      end
    {:noreply, socket}
  end

  # *** *******************************
  # *** FUNCTIONS

  def assign_header(socket) do
    assign(socket, header: "Dreadnought")
  end

  def standard_assigns(socket) do
    page_title = "Dreadnought"
    assign(socket, page_title: page_title)
  end

  # *** *******************************
  # *** SOCKET CONVERTERS

  # TODO this is ugly
  def mission(nil), do: nil
  def mission(%Mission{} = value), do: value
  def mission(socket), do: socket.assigns[:mission]

  def mission_in_progress?(socket) do
    with %Mission{} = mission <- mission(socket),
         true <- Mission.in_progress?(mission) do
      true
    else
      _ -> false
    end
  end

end
