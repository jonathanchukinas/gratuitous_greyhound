defmodule Dreadnought.Missions do

  use Dreadnought.Core.Mission.Spec
  alias Dreadnought.Core.ActionSelection
  alias Dreadnought.Core.Mission
  alias Dreadnought.Core.Player
  alias Dreadnought.Missions.DynamicSupervisor, as: MissionDynamicSupervisor
  alias Dreadnought.Missions.Registry, as: MissionRegistry
  alias Dreadnought.Players

  # *** *******************************
  # *** API

  def add_player(%Player{mission_spec: mission_spec} = player) do
    with :ok <- call_mission_server(mission_spec, {:add_player, player}),
         :ok <- Players.register_mission_name(player) do
      :ok
    end
  end

  def drop_player(player_uuid) when is_binary(player_uuid) do
    case Players.fetch_mission_spec(player_uuid) do
      {:ok, mission_spec} ->
        Players.drop_player(player_uuid)
        cast_mission_server(mission_spec, {:drop_player, player_uuid})
        :ok
      :error ->
        :error
    end
  end

  def get_by_mission_spec(mission_spec) when is_mission_spec(mission_spec) do
    call_mission_server mission_spec, :get
  end

  def get_by_player_uuid(player_uuid) do
    with {:ok, mission_spec} <- Players.fetch_mission_spec(player_uuid),
         {:ok, room}      <- fetch(mission_spec) do
      room
    else
      _response ->
        nil
    end
  end

  def fetch(mission_spec) when is_mission_spec(mission_spec) do
    case get_by_mission_spec(mission_spec) do
      nil -> :error
      room -> {:ok, room}
    end
  end

  def toggle_ready(mission_spec, player_id) when is_integer(player_id) do
    cast_mission_server mission_spec, {:toggle_ready, player_id}
  end

  def update_then_send_all(mission_spec, fun) do
    cast_mission_server mission_spec, {:update_then_send_all, fun}
  end

  def complete_player_turn(mission_spec, %ActionSelection{} = action_selection) do
    fun = &Mission.put(&1, action_selection)
    update_then_send_all(mission_spec, fun)
  end

  # *** *******************************
  # *** PRIVATE

  defp call_mission_server(mission_spec, msg) do
    mission_spec
    |> room_pid_from_name
    |> GenServer.call(msg)
  end

  defp cast_mission_server(mission_spec, msg) do
    mission_spec
    |> room_pid_from_name
    |> GenServer.cast(msg)
  end

  # TODO rename mission_pid_from_mission_spec
  defp room_pid_from_name(mission_spec) when is_mission_spec(mission_spec) do
    IOP.inspect mission_spec, __MODULE__
    with :error <- MissionRegistry.fetch_pid(mission_spec),
         {:ok, pid} <- MissionDynamicSupervisor.new_mission(mission_spec)  |> IOP.inspect(__MODULE__) do
      pid
    else
      {:ok, pid} -> pid
    end
  end

end
