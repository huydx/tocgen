defmodule Tocgen do
  alias Tocgen.RegexCase

  @moduledoc """

  """

  defmodule Indent,  do: defstruct h0: 0, h1: 0, h2: 0, h3: 0, h4: 0, h5: 0, level: 0

  @h0  ~r/^\s*# (.*)/
  @h1  ~r/^\s*## (.*)/
  @h2  ~r/^\s*### (.*)/
  @h3  ~r/^\s*#### (.*)/
  @h4  ~r/^\s*##### (.*)/

  def to_toc(list) do
    { _, toc } = Enum.reduce(list, {%Indent{}, ""}, &toc_reduce/2)
    IO.puts(toc)
  end

  defp toc_reduce(head, accumulator) do
    { current_indent, current_toc } = accumulator
    new_indent = indent_calculate(current_indent, head)
    new_toc = toc_calculate(current_toc, new_indent, head)
    { new_indent, new_toc }
  end

  defp toc_reduce([], accumulator) do
    accumulator
  end

  defp indent_calculate(current_indent, line) do
    cond do
      String.match?(line, @h0) -> %{current_indent | h0: current_indent.h0+1, h1: 0, h2: 0, h3: 0, h4: 0, level: 0}
      String.match?(line, @h1) -> %{current_indent | h1: current_indent.h1+1, h2: 0, h3: 0, h4: 0, level: 1}
      String.match?(line, @h2) -> %{current_indent | h2: current_indent.h2+1, h3: 0, h4: 0, level: 2}
      String.match?(line, @h3) -> %{current_indent | h3: current_indent.h3+1, h4: 0, level: 3}
      String.match?(line, @h4) -> %{current_indent | h4: current_indent.h4+1, level: 4}
      true -> current_indent
    end
  end

  @tr ~r/^\s*\#+\s+(?<title>.*)/
  defp toc_calculate(current_toc, new_indent, line) do
    title = Regex.named_captures(@tr, line)["title"]
    case title do
      nil -> current_toc
      "" -> current_toc
      _ -> "#{current_toc}\n #{String.Chars.to_string(new_indent)} - [#{title}](##{URI.encode(title)})"
    end
  end

  defimpl String.Chars, for: Indent do
    def to_string(i) do
      1..i.level |> Enum.map(fn _ -> " " end) |> Enum.join("")
    end
  end
end
