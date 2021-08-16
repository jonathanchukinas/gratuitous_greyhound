defmodule DreadnoughtWeb.MainLiveTest do

  use DreadnoughtWeb.ConnCase
  import Phoenix.LiveViewTest

  # *** *******************************
  # *** TESTS

  test "Redirect / to /dreadnought", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 302) =~ "/dreadnought"
  end

  # TODO follow the redirect to /dreadnought/play and test for player turn comp
  test "Multiplayer from Homepage", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/dreadnought")
    new_player = %{name: "Billy the Kid", mission_name: "flippy slippy"}
    view
    |> click("#link-multiplayer")
    |> assert_element("#new_player_component")
    |> form_submit("#add-player", new_player: new_player)
    |> assert_element("#lobby_component")
    #|> IOP.inspect
    |> click("#toggle-ready")

    assert_redirect(view, "/dreadnought/play")
    #view
    #|> IOP.inspect
    #|> assert_element("#player_turn_component")
  end

  #test "Quick Demo", %{conn: conn} do
  #  {:ok, view, _html} = live(conn, "/dreadnought")
  #  view
  #  |> element("#link-demo")
  #  |> render_click()
  #  assert has_element?(view, "#player_turn_component")
  #  assert has_element?(view, "#unit-1")
  #end

  test "Gallery from Homepage", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/dreadnought")
    assert view
    |> element("#link-gallery")
    |> render_click() =~ "Gallery"
  end

  # *** *******************************
  # *** ASSERTS - GENERAL HTML

  # TODO move these to a helper module
  defp assert_element(view, selector) do
    assert has_element?(view, selector)
    view
  end

  defp click(view, selector) do
    view
    |> element(selector)
    |> render_click
    #|> IOP.inspect("click on #{selector}")
    view
  end

  defp form_submit(view, selector, form_data) do
    view
    |> form(selector, form_data)
    |> render_submit
    view
  end

  #defp refute_element(view, selector, text_filter \\ nil) do
  #  refute has_element?(view, selector, text_filter)
  #  view
  #end

end
