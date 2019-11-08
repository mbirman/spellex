defmodule Spellex.Dictionary do
  def read do
    case File.read("dict/en.txt") do
      {:ok, dict} -> dict
      _ -> {:error, :ernoen}
    end
  end

  def words do
    read() |> String.downcase |> String.split(~r/\W+/, trim: true)
  end
end
