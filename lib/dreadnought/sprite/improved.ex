defmodule Dreadnought.Sprite.Improved do

    use Dreadnought.LinearAlgebra
    use Dreadnought.PositionOrientationSize
    use Dreadnought.Sprite.Spec
    use Dreadnought.TypedStruct
  alias Dreadnought.Sprite
  alias Dreadnought.Sprite.Builder
  alias Dreadnought.Svg

  # *** *******************************
  # *** TYPES

  typedstruct enforce: true do
    # TODO rename coords?
    field :points, [vector]
    # TODO postiion type
    field :image_position, any
  end

  # *** *******************************
  # *** CONSTRUCTORS

  def from_sprite_spec(sprite_spec) when is_sprite_spec(sprite_spec) do
    sprite = sprite_spec |> Builder.build
    image_position = Sprite.image_position(sprite)
    points =
      sprite.image_clip_path
      |> Svg.PathDString.to_coords
      |> Enum.map(&vector_add(&1, vector_from_position(image_position)))
    %__MODULE__{
      points: points,
      image_position: image_position
    }
  end

  # *** *******************************
  # *** CONVERTERS

  def coords(%__MODULE__{points: value}), do: value

  def polygon_points_string(%__MODULE__{points: points}) do
    Svg.polygon_points_string_from_coords(points)
  end

end
