defmodule SeedsHelper do
  def run_seeds do
    Code.require_file("priv/repo/seeds.exs")
  end
end
