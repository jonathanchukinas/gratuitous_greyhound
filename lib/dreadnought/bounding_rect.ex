alias Dreadnought.BoundingRect
alias Dreadnought.Geometry.Rect

defprotocol BoundingRect do
  def of(item)
end

defimpl BoundingRect, for: [Dreadnought.Core.Sprite] do
  def of(item), do: Rect.from_map(item)
end

defimpl BoundingRect, for: [Dreadnought.Core.Unit] do
  def of(%{rect: rect}), do: Rect.from_map(rect)
end

defimpl BoundingRect, for: [
  Dreadnought.PositionOrientationSize.Position,
  Dreadnought.PositionOrientationSize.Pose
] do
  def of(%{x: x, y: y}), do: Rect.new(x, y, 0, 0)
end

defimpl BoundingRect, for: Rect do
  def of(rect), do: rect
end

defimpl BoundingRect, for: List do
  def of([head | tail]) do
    start_rect = BoundingRect.of(head)
    Enum.reduce(tail, start_rect, fn term, rect ->
      term
      |> BoundingRect.of
      |> Rect.bounding_rect(rect)
    end)
  end
end

defimpl BoundingRect, for: Tuple do
    use Dreadnought.Sprite.Spec
  alias Dreadnought.Sprite.Improved, as: Sprite
  def of(sprite_spec) when is_sprite_spec(sprite_spec) do
    sprite_spec |> Sprite.from_sprite_spec |> BoundingRect.of
  end
end
