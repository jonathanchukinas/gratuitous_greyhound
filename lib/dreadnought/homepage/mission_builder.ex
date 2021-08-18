defmodule Dreadnought.Homepage.MissionBuilder do

  use Dreadnought.Core.Mission.Spec
  use Dreadnought.PositionOrientationSize
  use Dreadnought.Homepage.Helpers
  alias Dreadnought.Core.Mission
  alias Dreadnought.Core.Mission.Builder, as: MissionBuilder
  alias Dreadnought.Core.MissionHelpers
  alias Dreadnought.Core.Player
  alias Dreadnought.Core.Unit
  alias Dreadnought.Core.UnitBuilder

  @behaviour MissionBuilder

  # *** *******************************
  # *** CONSTRUCTORS

  @impl MissionBuilder
  def new(mission_name) do
    @starting_main_unit_id
    |> hull_by_unit_id
    |> do_new(@starting_main_unit_id, mission_name)
  end

  def do_new(hull, main_unit_id, mission_name) do
    {grid, margin} = MissionHelpers.medium_map()
    inputs = [
      Player.new_manual(@main_player_id),
      Player.new_manual(@target_player_id),
    ]
    Mission.new(new_mission_spec(__MODULE__, mission_name), grid, margin)
    |> Mission.put(inputs)
    |> put_target_unit
    |> put_main_unit(hull, main_unit_id)
    |> Mission.start
  end

  @impl MissionBuilder
  def mission_spec(mission_name) when is_binary(mission_name) do
    new_mission_spec(__MODULE__, mission_name)
  end

  # *** *******************************
  # *** PRIVATE REDUCERS

  defp put_main_unit(mission, hull, unit_id) do
    units =
      [
        target_unit(mission),
        UnitBuilder.build(hull, unit_id, @main_player_id) |> Unit.position_mass_center
      ]
    %Mission{mission | units: units}
  end

  defp put_target_unit(mission) do
    unit =
      :blue_destroyer
      |> UnitBuilder.build(@target_unit_id, @target_player_id)
    Mission.put(mission, unit)
  end

  # *** *******************************
  # *** PRIVATE CONVERTERS

  defp target_unit(mission), do: Mission.unit_by_id(mission, @target_unit_id)

end
