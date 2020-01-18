defmodule WifiCar.Vehicle do
  use Agent

  # vehicle state
  #   accelerator: {-100..100} integer
  #   steering:    {"L", "S", "R"} Left/Straight/Right
  defstruct accelerator: 0, steering: "S"

  alias WifiCar.Vehicle
  require Logger
  
  # turning radius & half width of vehicle [cm]
  @radius 20
  @half_w  6

  # GPIO port for each wheel
  @left   {23, 24}
  @right  {15, 18}

  @doc """
  Initialize vehicle state
  """
  def start_link(_) do
    Agent.start_link(fn -> %Vehicle{} end, name: __MODULE__)
  end
  
  @doc """
  Command: accelerator.
  """
  def accelerator(speed) do
    prev = Agent.get(__MODULE__, &(&1))
    curr = %Vehicle{prev | accelerator: speed}
    Agent.update(__MODULE__, fn _ -> curr end)

    drive_val(curr)
    |> Enum.each(&wheel/1)
  end
  
  @doc """
  Command: steering.
  """
  def steering(dir) do
    prev = Agent.get(__MODULE__, &(&1))
    curr = %Vehicle{prev | steering: dir}
    Agent.update(__MODULE__, fn _ -> curr end)

    drive_val(curr)
    |> Enum.each(&wheel/1)
  end
  
  def state do
  	Agent.get(__MODULE__, &(&1))
  end

  # calculate moter control valus from vehicle state.
  # Stop vehicle.
  defp drive_val(%Vehicle{accelerator: 0}) do
  	[
  	  {@left,  0},
  	  {@right, 0}
  	]
  end

  # Turn left.
  defp drive_val(%Vehicle{steering: "L", accelerator: speed}) do
  	[
      {@left,  div(255*(@radius-@half_w)*speed, @radius*100)},
      {@right, div(255*(@radius+@half_w)*speed, @radius*100)}
    ]
  end
  
  # Go straight.
  defp drive_val(%Vehicle{steering: "S", accelerator: speed}) do
    [
      {@left,  div(255*speed, 100)},
      {@right, div(255*speed, 100)}
    ]
  end

  # Turn right.
  defp drive_val(%Vehicle{steering: "R", accelerator: speed}) do
    [
      {@left,  div(255*(@radius+@half_w)*speed, @radius*100)},
      {@right, div(255*(@radius-@half_w)*speed, @radius*100)}
    ]
  end
  
  # Apply control value to the moter H-bridge
  defp wheel({{port_a, port_b}, val}) do
    {a, b} = cond do
      val >  0 -> {val, 0}
      val == 0 -> {0, 0}
      val <  0 -> {0, -val}
    end
    Pigpiox.Pwm.gpio_pwm(port_a, a)
    Pigpiox.Pwm.gpio_pwm(port_b, b)

    Logger.info("PORT(#{port_a}) <- #{a}")
    Logger.info("PORT(#{port_b}) <- #{b}")
  end
end
