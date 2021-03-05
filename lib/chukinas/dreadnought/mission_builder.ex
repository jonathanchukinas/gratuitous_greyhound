alias Chukinas.Dreadnought.{Mission, Unit, Command, CommandQueue, CommandIds, MissionBuilder}
alias Chukinas.Geometry.{Pose}

defmodule MissionBuilder do

  def demo() do
    commands =
      1..5
      |> Enum.map(&Command.random/1)
    deck =
      CommandQueue.new(2, commands)
      |> CommandQueue.draw(5)
    Mission.new()
    |> Mission.set_arena(1000, 750)
    |> Mission.put(Unit.new(2, start_pose: Pose.new(0, 0, 45)))
    |> Mission.put(deck)
    |> IOP.inspect("demo mission!!!")
    |> Mission.issue_command(CommandIds.new 2, 1, 5)
  end
end
