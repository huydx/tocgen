defmodule Tocgen.CLI do

  def main(argv) do
    argv |> parse_args |> process
  end

  @args """
  usage
  tocgen --help
  tocgen --version
  tocgen [ .. <file> ]
  """

  defp parse_args(argv) do
    switches = [
      help: :boolean,
      version: :boolean
    ]
    aliases = [
      h: :help,
      v: :version
    ]

    parse = OptionParser.parse(argv, switches: switches, aliases: aliases)
    case parse do
      { [{switch, true}], _, _ } -> switch
      { [], [ filename ], [] } -> { open_file(filename) }
      _ -> :help
    end
  end

  defp process(:help) do
    IO.puts(:stderr, @args)
  end

  defp process(:version) do
    {:ok, version} = :application.get_key(:tocgen, :vsn)
    IO.puts( version )
  end

  defp process({io_device}) do
    content = IO.stream(io_device, :line) |> Enum.to_list
    Tocgen.to_toc(content)
  end

  defp open_file(filename), do: io_device(File.open(filename, [:utf8]), filename)
  defp io_device({:ok, io_device}, _), do: io_device
  defp io_device({:error, reason}, filename) do
    IO.puts(:stderr, "#{filename}: #{:file.format_error(reason)}")
    exit(1)
  end
end
