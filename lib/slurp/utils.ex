defmodule Slurp.Utils do
  defdelegate integer_to_hex(i), to: ExW3.Utils
  defdelegate hex_to_integer(h), to: ExW3.Utils
end
