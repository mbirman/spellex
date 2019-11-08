defmodule Spellex do
  @words Spellex.Dictionary.words()
  @letters String.split("abcdefghijklmnopqrstuvwxyz", "")

  @moduledoc """
  Documentation for Spellex.
  """

  @doc """
  Returns a list of possible corrections for a `word`.
  
  ## Examples

    iex> Spellex.corrections("wrod")
    {:ok, ["word"]}

    iex> Spellex.corrections("")
    {:ok, []}

    iex> Spellex.corrections(1)
    {:error, :invalid_input}
  """

  @spec corrections(binary) :: {:error, :invalid_input}
  def corrections(word) when not is_binary(word), do: {:error, :invalid_input}

  @spec corrections(binary) :: {:ok, List.t()}
  def corrections(word) when word == "", do: {:ok, []}

  @spec corrections(binary) :: {:ok, List.t()}
  def corrections(word) when is_binary(word) do
    {:ok, Enum.uniq(known([word]) ++ one_edit_away(word) ++ [word])}
  end

  @doc """
  Returns the most probable correction for a `word`.
  
  ## Examples

    iex> Spellex.correction("wrod")
    {:ok, "word"}

    iex> Spellex.correction("")
    {:ok, ""}

    iex> Spellex.correction(1)
    {:error, :invalid_input}
  """

  @spec correction(binary) :: {:error, :invalid_input}
  def correction(word) when not is_binary(word), do: {:error, :invalid_input}

  @spec correction(binary) :: {:ok, String.t()}
  def correction(word) when word == "", do: {:ok, ""}

  @spec correction(binary) :: {:ok, String.t()}
  def correction(word) when is_binary(word) do
    {:ok, corrections} = corrections(word)

    {:ok, Enum.max_by(corrections, &probability/1)}
  end

  defp probability(word) do
    case Enum.count(@words, fn el -> el == word end) do
      0 -> 0
      p ->  Enum.count(@words) / p
    end
  end

  defp known(words) do
    for w <- words, Enum.find(@words, fn el -> el == w end), do: w
  end

  defp one_edit_away(word) do
    Enum.uniq(deletes(word) ++ transposes(word) ++ replaces(word) ++ inserts(word))
  end

  def splits(word) do
    for i <- 0..String.length(word), do: String.split_at(word, i)
  end

  defp deletes(word) do
    splits(word)
      |> Enum.filter(fn {_left, right} -> right != "" end)
      |> Enum.map(fn {left, right} -> left <> elem(String.split_at(right, 1), 1) end)
  end

  defp transposes(word) do
    splits(word)
      |> Enum.filter(fn {_left, right} -> String.length(right) > 1 end)
      |> Enum.map(fn {left, right} -> left <> String.at(right, 1) <> String.at(right, 0) <> elem(String.split_at(right, 2), 1) end)
  end

  defp replaces(word) do
    splits(word)
      |> Enum.filter(fn {_left, right} -> right != "" end)
      |> Enum.map(fn {left, right} ->
        Enum.map(@letters, fn letter -> left <> letter <> elem(String.split_at(right, 1), 1) end)
      end)
      |> List.flatten
      |> Enum.uniq
  end

  defp inserts(word) do
    splits(word)
      |> Enum.filter(fn {_left, right} -> right != "" end)
      |> Enum.map(fn {left, right} ->
        Enum.map(@letters, fn letter -> left <> letter <> right end)
      end)
      |> List.flatten
      |> Enum.uniq
  end
end
