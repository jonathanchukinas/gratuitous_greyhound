defmodule Chukinas.Dreadnought.MissionBuilder do

  use Chukinas.LinearAlgebra
  use Chukinas.PositionOrientationSize
  alias Chukinas.Dreadnought.ActionSelection
  alias Chukinas.Dreadnought.Island
  alias Chukinas.Dreadnought.Mission
  alias Chukinas.Dreadnought.Player
  alias Chukinas.Dreadnought.Unit
  alias Chukinas.Dreadnought.UnitAction
  alias Chukinas.Dreadnought.UnitBuilder
  alias Chukinas.Geometry.Grid

  # *** *******************************
  # *** CONSTRUCTORS

  @spec homepage :: Mission.t
  def homepage do
    {grid, margin} = medium_map()
    inputs = [
      Player.new_manual(1),
      Player.new_manual(2),
    ]
    units = [
      UnitBuilder.build(:blue_destroyer, 1, 1) |> Unit.position_mass_center,
      UnitBuilder.build(:blue_destroyer, 2, 2)
    ]
    Mission.new("homepage", grid, margin)
    |> Mission.put(inputs)
    |> Mission.put(units)
    |> Mission.start
    |> homepage_1_fire_upon_2
  end

  def homepage_1_fire_upon_2(mission) do
    units = Mission.units(mission)
    action_selection =
      ActionSelection.new(1, units, [])
      |> ActionSelection.put(UnitAction.fire_upon(1, 2))
    mission
    |> position_target_randomly_within_arc
    |> Mission.put_action_selection_and_end_turn(action_selection)
  end

  defp position_target_randomly_within_arc(mission) do
    target_pose =
      mission
      |> Mission.unit_by_id(1)
      |> Unit.world_coord_random_in_arc(500)
      |> pose_from_vector
    Mission.update_unit mission, 2, &merge_pose!(&1, target_pose)
  end

  @spec online(String.t) :: Mission.t
  def online(room_name) do
    {grid, margin} = medium_map()
    Mission.new(room_name, grid, margin)
    |> Map.put(:islands, islands())
    # Still needs players, units, and needs to be started
  end

  # *** *******************************
  # *** REDUCERS

  def add_player(%Mission{} = mission, player_uuid, player_name) do
    player_id = 1 + Mission.player_count(mission)
    player = Player.new_human(player_id, player_uuid, player_name)
    Mission.put(mission, player)
  end

  def maybe_start(%Mission{} = mission) do
    if ready?(mission) do
      mission
      |> put_fleets
      |> Mission.start
    else
      mission
    end
  end

  # *** *******************************
  # *** PRIVATE CONVERTERS

  @spec all_players_ready?(Mission.t) :: boolean
  defp all_players_ready?(mission) do
    mission
    |> Mission.players
    |> Enum.all?(&Player.ready?/1)
  end

  @spec put_fleets(Mission.t) :: Mission.t
  defp put_fleets(%Mission{} = mission) do
    player_ids_and_fleet_colors = Enum.zip([
      Mission.player_ids(mission),
      [:red, :blue],
      # TODO second pose needs to be relative to bl corner of play area
      [pose_new(100, 100, 45), pose_new(500, 500, -135)]
    ])
    Enum.reduce(player_ids_and_fleet_colors, mission, fn {player_id, color, pose}, mission ->
      next_unit_id = Mission.unit_count(mission) + 1
      units = build_fleet(color, next_unit_id, player_id, pose)
      Mission.put(mission, units)
    end)
  end

  @spec ready?(Mission.t) :: boolean
  defp ready?(%Mission{} = mission) do
    with true <- Mission.player_count(mission) in 1..2,
         true <- all_players_ready?(mission) do
      true
    else
      false -> false
    end
  end

  # *** *******************************
  # *** PRIVATE HELPERS

  defp islands do
    [
      position_new(500, 500),
      position_new(2500, 1200),
      position_new(1500, 1800),
    ]
    |> Enum.with_index
    |> Enum.map(fn {position, index} ->
      position = position_shake position
      Island.random(index, position)
    end)
  end

  def small_map, do: grid_and_margin(800, 500)
  def medium_map, do: grid_and_margin(1400, 700)
  def large_map, do: grid_and_margin(3000, 2000)

  def grid_and_margin(width, height) do
    square_size = 50
    arena = %{
      width: width,
      height: height
    }
    margin = size_new(arena.height, arena.width)
    [square_count_x, square_count_y] =
      [arena.width, arena.height]
      |> Enum.map(&round(&1 / square_size))
    grid = Grid.new(square_size, position_new(square_count_x, square_count_y))
    {grid, margin}
  end

  def build_fleet(:red, starting_id, player_id, pose) do
    formation =
      [
        {  0,   0},
        {-50,  50},
        {-50, -50},
      ]
    poses = for unit_coord <-formation, do: formation_to_pose(pose, unit_coord)
    [
      UnitBuilder.build(:red_cruiser, starting_id, player_id, Enum.at(poses, 0), name: "Navarin"),
      UnitBuilder.build(:red_destroyer, starting_id + 1, player_id, Enum.at(poses, 1), name: "Potemkin"),
      UnitBuilder.build(:red_destroyer, starting_id + 2, player_id, Enum.at(poses, 2), name: "Sissoi")
    ]
  end

  def build_fleet(:blue, starting_id, player_id, pose) do
    formation =
      [
        {  0,   0},
        {-50,  50},
      ]
    poses = for unit_coord <-formation, do: formation_to_pose(pose, unit_coord)
    [
      UnitBuilder.build(:blue_dreadnought, starting_id, player_id, Enum.at(poses, 0), name: "Washington"),
      UnitBuilder.build(:blue_destroyer, starting_id + 1, player_id, Enum.at(poses, 1), name: "Detroit")
    ]
  end

  def human_and_ai_players do
    [
      Player.new_human(1, "PLACEHOLDER", "Billy Jane"),
      Player.new_ai(2, "PLACEHOLDER", "R2-D2")
    ]
  end

  def formation_to_pose(lead_pose, unit_coord_wrt_pose) when has_pose(lead_pose) and is_vector(unit_coord_wrt_pose) do
    lead_pose
    |> csys_from_pose
    |> csys_translate(unit_coord_wrt_pose)
    |> csys_to_pose
  end

end
