defmodule OptionParserPlus do
  @moduledoc """
  `OptionParserPlus receives the same arguments as option parser,
  When the strict option is specified then it checks also 
  if keys that were passed but not set on the command line 
  are set as env variables written with capital letters

  iex(1)> OptionParserPlus.parse([], strict: [debug: :boolean])
  {[debug: false], [], []}
  iex(2)> System.put_env("DEBUG", "true")
  :ok
  iex(3)> OptionParserPlus.parse([], strict: [debug: :boolean])
  {[debug: true], [], []}
  iex(4)> OptionParserPlus.parse([], strict: [debug: :string])
  {[debug: "true"], [], []}
  iex(5)> System.delete_env("DEBUG")
  :ok
  iex(6)> OptionParserPlus.parse([], strict: [debug: :string])
  {[], [], []}
  """

  def parse(args, opts \\ []) do
    {new_strict, lists} = replace_list_with_string(opts[:strict])

    compatible_opts = Keyword.put(opts, :strict, new_strict)
    {cmd_parsed, rest, err} = OptionParser.parse(args, compatible_opts)

    {env_parsed, _, _} =
      Enum.reduce(opts[:strict], [], fn {key, type}, acc ->
        if Keyword.get(cmd_parsed, key) do
          acc
        else
          convert_to_option_parser(acc, key, type)
        end
      end)
      |> OptionParser.parse(opts)

    all_parsed =
      if length(lists) > 0 do
        split_lists(env_parsed ++ cmd_parsed, lists)
      else
        env_parsed ++ cmd_parsed
      end

    {all_parsed, rest, err}
  end

  defp replace_list_with_string(params) do
    params
    |> Enum.reduce({[], []}, fn {key, value}, {compatible_opts, lists} ->
      if value == :list do
        {[{key, :string} | compatible_opts], [key | lists]}
      else
        {[{key, value} | compatible_opts], lists}
      end
    end)
  end

  def convert_to_option_parser(acc, key, type) do
    value = get_from_env(key)

    case type do
      :boolean ->
        [if(value == "true", do: "--", else: "--no-") <> Atom.to_string(key) | acc]

      _ ->
        if value, do: ["--" <> Atom.to_string(key), value | acc], else: acc
    end
  end

  def get_from_env(key) do
    key
    |> Atom.to_string()
    |> String.upcase()
    |> System.get_env()
  end

  def split_lists(parsed, lists) do
    Enum.map(parsed, fn {key, value} ->
      if key in lists do
        {key, String.split(value, ",")}
      else
        {key, value}
      end
    end)
  end
end
