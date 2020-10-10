defmodule Slurp.IEx.Commands.HelpTest do
  use ExUnit.Case, async: true
  import ExUnit.CaptureIO

  test "show command usage" do
    assert capture_io(&Slurp.IEx.help/0) != ""
  end
end
