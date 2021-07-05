defmodule ChukinasWeb.DreadnoughtPlayView do

  use ChukinasWeb, :view
  use Chukinas.LinearAlgebra
  use Chukinas.PositionOrientationSize
  alias Chukinas.Dreadnought.Unit
  alias Chukinas.Dreadnought.Unit.Event.Maneuver
  alias Chukinas.Dreadnought.ActionSelection, as: AS
  alias Chukinas.Geometry.Rect

  # TODO rename
  def render_single_maneuver(%Maneuver{} = path, unit_id) do
    assigns =
      path
      |> Map.from_struct
      |> Map.put(:unit_el_id, "unit-#{unit_id}")
    render("maneuver_path.html", assigns)
  end

  def render_single_maneuver(_, _) do
    nil
  end

  # TODO swap the two params
  def render_unit_selection_box(target \\ nil, %Unit{} = unit) do
    box_size = 200
    box_position =
      unit
      |> Unit.center_of_mass
      # TODO I shouldn't have to put unit in a list
      |> vector_inner_to_outer([unit])
      |> position_from_vector
      |> position_subtract(box_size / 2)
    assigns =
      [
        unit_id: unit.id,
        unit_name: unit.name,
        size: box_size,
        position: box_position,
        # TODO rename `target`
        myself: target
      ]
    render("_unit_selection_box.html", assigns)
  end

  def render_action_selection(action_selection, target \\ nil)

  def render_action_selection(nil, _), do: nil

  def render_action_selection(%AS.Maneuver{} = action_selection, target) do
    render "action_selection_maneuver.html", action_selection: action_selection, target: target
  end

  def render_zoom_pan_fit_area(arena_size) do
    margin = 50
    position =
      position_null()
      |> position_subtract(margin)
    size =
      arena_size
      |> size_add(2 * margin)
    rect = Rect.from_position_and_size(
      position,
      size
    )
    render "zoom_pan_fit_area.html", rect: rect
  end

  def render_rect_as_style_attrs(rect) do
    map_to_string = fn
      {:x, val} -> "left: #{val}px;"
      {:y, val} -> "right: #{val}px;"
      {:width, val} -> "width: #{val}px;"
      {:height, val} -> "height: #{val}px;"
    end
    rect
    |> Rect.from_rect
    |> Map.from_struct
    |> Enum.map(map_to_string)
    # TODO investigate using io list
    |> Enum.join(" ")
  end

end
