defmodule DreadnoughtWeb.SpriteComponent do

    use DreadnoughtWeb, :live_component
    use Dreadnought.LinearAlgebra
    use Dreadnought.PositionOrientationSize
  # TODO Spec functions should be aliased. Import only the guards
    use Dreadnought.Sprite.Spec
  alias Dreadnought.BoundingRect
  alias Dreadnought.Sprite.Improved
  alias DreadnoughtWeb.SvgView

  # *** *******************************
  # *** CONSTRUCTORS

  def render_list(sprite_specs) when is_list(sprite_specs) do
    Phoenix.LiveView.Helpers.live_component(__MODULE__, sprite_specs: sprite_specs)
  end

  def render_single_as_block(sprite_spec) when is_sprite_spec(sprite_spec) do
    Phoenix.LiveView.Helpers.live_component(__MODULE__, sprite_specs: [sprite_spec], as_block: true)
  end

  # *** *******************************
  # *** CALLBACKS

  @impl true
  def mount(socket) do
    {:ok, socket}
  end

  @impl true
  def update(%{sprite_specs: sprite_specs} = assigns, socket) do
    socket =
      socket
      |> assign(sprite_specs: sprite_specs)
      |> assign(as_block: !!assigns[:as_block])
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~L"""
    <%# TODO use dynamic values %>
    <svg id="sprite_component" viewbox="0 0 1000 1000" width="1000" height="1000" overflow="visible" >
      <defs>
        <%= _render_shape_defs(@sprite_specs) %>
        <%= _render_clippath_defs(@sprite_specs) %>
        <%= _render_sprite_defs(@sprite_specs, @socket) %>
      </defs>
      <%= _render_sprite_uses(@sprite_specs, @as_block) %>
    </svg>
    """
  end

  # TODO reduce duplication

  # *** *******************************
  # *** SPRITE.SPEC.LIST CONVERTERS

  def _render_shape_defs(sprite_specs) when is_list(sprite_specs) do
    for sprite_spec <- sprite_specs, do: _render_shape_def(sprite_spec)
  end

  def _render_clippath_defs(sprite_specs) when is_list(sprite_specs) do
    for sprite_spec <- sprite_specs, do: _render_clippath_def(sprite_spec)
  end

  def _render_sprite_defs(sprite_specs, socket) when is_list(sprite_specs) do
    for sprite_spec <- sprite_specs, do: _render_sprite_def(sprite_spec, socket)
  end

  def _render_sprite_uses(sprite_specs, as_block) when is_list(sprite_specs) do
    for sprite_spec <- sprite_specs, do: _render_sprite_use(sprite_spec, as_block)
  end

  # *** *******************************
  # *** SPRITE.SPEC CONVERTERS

  defp _render_shape_def(sprite_spec) when is_sprite_spec(sprite_spec) do
    sprite = Improved.from_sprite_spec(sprite_spec)
    coords = Improved.coords(sprite)
    SvgView.render_polygon(coords,
      id: _element_id(sprite_spec, :shape)
    )
  end

  defp _render_clippath_def(sprite_spec) when is_sprite_spec(sprite_spec) do
    id = _element_id(sprite_spec, :clippath)
    href_id = _element_id(sprite_spec, :shape)
    SvgView.render_clippath_use(id, href_id)
  end

  defp _render_sprite_def(sprite_spec, socket) when is_sprite_spec(sprite_spec) do
    content = [
      _render_dropshadow(sprite_spec),
      _render_clipped_image(sprite_spec, socket),
    ]
    content_tag(:g, content, id: _element_id(sprite_spec, :sprite))
  end

  defp _render_clipped_image(sprite_spec, socket) when is_sprite_spec(sprite_spec) do
    improved_sprite = Improved.from_sprite_spec(sprite_spec)
    href = Routes.static_path(socket, Improved.image_path(improved_sprite))
    size = Improved.image_size(improved_sprite)
    position = improved_sprite.image_position
    # TODO create new render_clipped_image
    SvgView.render_image(href, size,
      x: position.x,
      y: position.y,
      clip_path: "url(##{_element_id(sprite_spec, :clippath)})"
    )
  end

  defp _render_dropshadow(sprite_spec) when is_sprite_spec(sprite_spec) do
    href_id = _element_id(sprite_spec, :shape)
    SvgView.render_dropshadow_use(href_id)
  end

  defp _render_sprite_use(sprite_spec, as_block) when is_sprite_spec(sprite_spec) and is_boolean(as_block) do
    href_id = _element_id(sprite_spec, :sprite)
    bounding_rect = sprite_spec |> Improved.from_sprite_spec |> BoundingRect.of
    attrs =
      if as_block do
        [
          x: -bounding_rect.x,
          y: -bounding_rect.y
        ]
      else
        []
      end
    SvgView.render_use(href_id, attrs)
  end

  defp _element_id(sprite_spec, :shape) do
    _element_id(sprite_spec, :sprite) <> "-shape"
  end
  defp _element_id(sprite_spec, :clippath) do
    _element_id(sprite_spec, :sprite) <> "-clippath"
  end
  defp _element_id({func_name, arg} = sprite_spec, :sprite)
  when is_sprite_spec(sprite_spec) do
    "sprite-#{func_name}-#{arg}"
  end

end
