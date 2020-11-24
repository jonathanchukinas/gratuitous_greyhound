defmodule Chukinas.Skies.Spec do
  alias Chukinas.Skies.Spec.Map
  alias Chukinas.Skies.Game.Boxes, as: Positions

  def build(map_id) do
    {spaces, elements} = Map.build(map_id)
    %{
      spaces: spaces,
      elements: elements,
      # FIX not needed
      boxes: Positions.build()
    }
  end

end
