alias Chukinas.Dreadnought.{Unit, Mission, ById, CommandQueue, Segment, CommandIds}
alias Chukinas.Geometry.{Rect}

defmodule Mission do

  # *** *******************************
  # *** TYPES

  use TypedStruct

  typedstruct enforce: true do
    field :state, atom(), default: :pregame
    field :arena, Rect.t(), enforce: false
    field :units, [Unit.t()], default: []
    field :decks, [CommandQueue.t()], default: []
    field :segments, [Segment.t()], default: []
  end

  # *** *******************************
  # *** NEW

  def new(), do: %__MODULE__{}

  # *** *******************************
  # *** GETTERS

  def unit(%__MODULE__{} = mission, %CommandIds{unit: id}), do: unit(mission, id)
  def unit(%__MODULE__{} = mission, id), do: ById.get(mission.units, id)
  def get_unit(%__MODULE__{} = mission, id), do: unit(mission, id)

  def deck(%__MODULE__{} = mission, %CommandIds{unit: id}) do
    mission.decks |> ById.get(id)
  end

  def segment(%__module__{} = mission, unit_id, segment_id) do
    mission.segments
    |> Enum.find(fn seg -> Segment.match?(seg, unit_id, segment_id) end)
  end

  # TODO use the bang on the other getters that need it
  def arena!(%__MODULE__{arena: nil}), do: raise "Error: no arena has been set!"
  def arena!(%__MODULE__{arena: arena}), do: arena

  # *** *******************************
  # *** SETTERS

  # TODO rename put
  # TODO are these private?
  # TODO it would be easier if these were maps. Units and Decks would be maps; Segments a list
  def push(%__MODULE__{units: units} = mission, %Unit{} = unit) do
    %{mission | units: ById.insert(units, unit)}
  end
  def push(%__MODULE__{decks: decks} = mission, %CommandQueue{} = deck) do
    %{mission | decks: ById.insert(decks, deck)}
  end

  def put(mission, unit), do: push(mission, unit)

  def set_arena(%__MODULE__{} = mission, width, height) do
    %{mission | arena: Rect.new(width, height)}
  end
  # TODO get rid of this one
  def set_arena(%__MODULE__{} = mission, %Rect{} = arena) do
    %{mission | arena: arena}
  end
  def set_segments(%__MODULE__{} = mission, segments) do
    %{mission | segments: segments}
  end

  # *** *******************************
  # *** API

  def issue_command(%__MODULE__{} = mission, %CommandIds{} = cmd) do
    deck =
      mission
      |> deck(cmd)
      |> CommandQueue.issue_command(cmd)
    start_pose = mission |> unit(cmd) |> Unit.start_pose()
    segments = CommandQueue.build_segments(deck, start_pose, mission.arena)
    mission
    |> push(deck)
    |> set_segments(segments)
  end

  # *** *******************************
  # *** PRIVATE

  # defp update_unit_segments(%__MODULE__{} = mission) do
  #   unit_ids =
  #     mission.decks
  #     |> Enum.map(&CommandQueue.get_id/1)
  #   update_unit_segments(mission, unit_ids)
  # end

  # defp update_unit_segments(%__MODULE__{} = mission, [id]) do
  #   update_unit_segments(mission, id)
  # end

  # defp update_unit_segments(%__MODULE__{} = mission, [id | remaining_ids]) do
  #   update_unit_segments(mission, id)
  #   |> update_unit_segments(remaining_ids)
  # end

  # defp update_unit_segments(%__MODULE__{} = mission, unit_id) when is_integer(unit_id) do
  #   deck = get_deck mission, unit_id
  #   unit = get_unit(mission, unit_id)
  #   start_pose = unit |> Unit.start_pose()
  #   arena = mission.arena
  #   segments = CommandQueue.build_segments deck, start_pose, arena
  #   unit = Unit.set_segments(unit, segments)
  #   push(mission, unit)
  # end
end
