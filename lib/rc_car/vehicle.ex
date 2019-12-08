defmodule RcCar.Vehicle do
  use Agent

  defstruct accelerator: 0, steering: "S"

  alias RcCar.Vehicle
  require Logger
  
  @left   {15, 18}
  @right  {23, 24}
  @radius 20

  def start_link(_) do
    Agent.start_link(fn -> %Vehicle{} end, name: __MODULE__)
  end
  
  def accelerator(speed) do
    prev = Agent.get(__MODULE__, &(&1))
    curr = %Vehicle{prev | accelerator: speed}
    Agent.update(__MODULE__, fn _ -> curr end)

    drive_val(curr)
    |> Enum.each(&wheel/1)
  end
  
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

  defp drive_val(%Vehicle{accelerator: 0}) do
  	[
  	  {@left,  0},
  	  {@right, 0}
  	]
  end

  defp drive_val(%Vehicle{steering: "L", accelerator: speed}) do
  	[
  	  {@left,  div((@radius+6)*255*speed, @radius*100)},
      {@right, div((@radius-6)*255*speed, @radius*100)}
    ]
  end
  
  defp drive_val(%Vehicle{steering: "S", accelerator: speed}) do
    [
      {@left,  div(255*speed, 100)},
      {@right, div(255*speed, 100)}
    ]
  end

  defp drive_val(%Vehicle{steering: "R", accelerator: speed}) do
    [
      {@left,  div((@radius-6)*255*speed, @radius*100)},
      {@right, div((@radius+6)*255*speed, @radius*100)}
    ]
  end
  
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
