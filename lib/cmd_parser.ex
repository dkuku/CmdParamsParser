defmodule CmdParamsParser do
  @moduledoc """
  `CmdParser receives the same arguments as option parser,
  When the strict option is specified then it checks also 
  if keys that were passed but not set on the command line 
  are set as env variables written with capital letters

  iex(1)> CmdParamsParser.parse([], strict: [debug: :boolean])
  {[debug: false], [], []}
  iex(2)> System.put_env("DEBUG", "true")
  :ok
  iex(3)> CmdParamsParser.parse([], strict: [debug: :boolean])
  {[debug: true], [], []}
  iex(4)> CmdParamsParser.parse([], strict: [debug: :string])
  {[debug: "true"], [], []}
  iex(5)> System.delete_env("DEBUG")
  :ok
  iex(6)> CmdParamsParser.parse([], strict: [debug: :string])
  {[], [], []}
  """

  def parse(args, opts \\ []) do
    {parsed, rest, err} = OptionParser.parse(args, opts)

    {env_parsed, _, _} =
      Enum.reduce(opts[:strict], [], fn {key, type}, acc ->
        value =
          key
          |> Atom.to_string()
          |> String.upcase()
          |> System.get_env()

        if Keyword.get(parsed, key) do
          acc
        else
          case type do
            :boolean ->
              [if(value == "true", do: "--", else: "--no-") <> Atom.to_string(key) | acc]

            _ ->
              if value, do: ["--" <> Atom.to_string(key), value | acc], else: acc
          end
        end
      end)
      |> OptionParser.parse(opts)

    {env_parsed ++ parsed, rest, err}
  end
end
