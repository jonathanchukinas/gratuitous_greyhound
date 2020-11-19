defmodule Chukinas.Skies.Game.Squadron do
  alias Chukinas.Skies.Game.{Fighter, FighterGroup}
  import Chukinas.Skies.Game.IdAndState

  # *** *******************************
  # *** TYPES

  defstruct [
    :groups,
    :fighters,
  ]

  @type t :: %__MODULE__{
    groups: [FighterGroup.t()],
    fighters: [Fighter.t()],
  }

  # *** *******************************
  # *** NEW

  @spec new() :: t()
  def new() do
    1..3
    |> Enum.map(&Fighter.new/1)
    |> rebuild()
  end

  @spec build([Fighter.t()], [FighterGroup.t()]) :: t()
  def build(fighters, groups) do
    %__MODULE__{fighters: fighters, groups: groups}
  end

  def rebuild(fighters) do
    groups = FighterGroup.build_groups(fighters)
    build(fighters, groups)
  end

  # *** *******************************
  # *** API

  @spec select_group(t(), integer()) :: t()
  def select_group(squadron, group_id) do
    groups = squadron.groups
    |> Enum.map(&FighterGroup.unselect/1)
    |> apply_if_matching_id(group_id, &FighterGroup.select/1)
    fighter_ids = groups
    |> get_item(group_id)
    |> Map.fetch!(:fighter_ids)
    fighters = squadron.fighters
    |> apply_if_matching_id(fighter_ids, &Fighter.select/1)
    build(fighters, groups)
  end

  @spec toggle_fighter_select(t(), integer()) :: t()
  def toggle_fighter_select(squadron, fighter_id) do
    squadron.fighters
    |> apply_if_matching_id(fighter_id, &Fighter.toggle_select/1)
    |> update_fighters(squadron)
  end

  @spec delay_entry(t()) :: t()
  def delay_entry(squadron) do
    fighter_ids = squadron.groups
    |> get_single_selected()
    |> Map.fetch!(:fighter_ids)
    squadron.fighters
    |> apply_if_matching_id(fighter_ids, &Fighter.delay_entry/1)
    |> rebuild()
  end

  @spec all_fighters_delayed_entry?(t()) :: boolean()
  def all_fighters_delayed_entry?(squadron) do
    squadron.fighters
    |> Enum.all?(&Fighter.delayed_entry?/1)
  end

  def any_fighters?(squadron, fun) do
    squadron.fighters
    |> Enum.any?(fun)
  end

  # *** *******************************
  # *** HELPERS

  @spec update_fighters([Fighter.t()], t()) :: t()
  defp update_fighters(fighters, squadron) do
    %{squadron | fighters: fighters}
  end

end
