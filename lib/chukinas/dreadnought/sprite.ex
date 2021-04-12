alias Chukinas.Dreadnought.{Sprite, Mount}
alias Chukinas.Geometry.{Position, Size}
alias Chukinas.Svg.Interpret

defmodule Sprite do

  use TypedStruct

  # TODO add name
  typedstruct enforce: true do
    # Note: `rel` means relative to origin (the sprite's 'center')
    field :origin, Position.t()
    # TODO Rename abs_start
    field :start, Position.t()
    field :start_rel, Position.t()
    field :size, Size.t()
    # TODO is this useful?
    field :mountings, [Mount.t()]
    field :image, Sprite.Image.t()
    field :clip_path, String.t()
  end

  def from_parsed_spritesheet(sprite, image_map) do
    svg = sprite.clip_path |> Interpret.interpret|> IOP.inspect("svg interp")
    size = Size.from_positions(svg.min, svg.max)
    image = Sprite.Image.new(
      "/images/spritesheets/" <> image_map.path.name,
      image_map.width,
      image_map.height
    )
    origin = Position.new(sprite.origin)
    %__MODULE__{
      # TODO this isn't a Position.t()
      origin: origin,
      start: svg.min,
      start_rel: Position.subtract(svg.min, origin),
      size: size,
      mountings: sprite.mountings |> Enum.map(& struct(Mount, &1)),
      image: image,
      clip_path: sprite.clip_path
    }
  end

  # TODO delete
  def from_unitbuilder(map) do
    rect = map.rect
    map =
      map
      |> Map.put(:start, Position.new(rect.x, rect.y))
      |> Map.put(:size, Size.new(rect.width, rect.height))
      |> Map.put(:start_rel, Position.new(-rect.half_width, -rect.half_height))
      |> Map.put(:mountings, map.mountings |> Enum.map(& struct(Mount, &1)))
      |> Map.put(:image, struct(Sprite.Image, map.image))
    struct(__MODULE__, map)
  end
end

# TODO rename Mounting
defmodule Mount do
  use TypedStruct
  typedstruct do
    field :id, integer()
    field :position, Position.t()
  end
end

defmodule Sprite.Image do
  use TypedStruct
  typedstruct do
    field :path, String.t()
    field :size, Size.t()
  end
  def new(path, width, height) do
    %__MODULE__{
      path: path,
      size: Size.new(width, height)
    }
  end
end
