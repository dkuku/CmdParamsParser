defmodule OptionParserPlusTest do
  use ExUnit.Case
  doctest OptionParserPlus

  test "parses boolean options from options list" do
    assert OptionParserPlus.parse(["--debug"], strict: [debug: :boolean]) ==
             {[debug: true], [], []}
  end

  test "parses boolean options from system variables" do
    System.put_env("DEBUG", "true")
    assert OptionParserPlus.parse([], strict: [debug: :boolean]) == {[debug: true], [], []}
    System.delete_env("DEBUG")
  end

  test "parses string options from options list" do
    assert OptionParserPlus.parse(["--debug", "true"], strict: [debug: :string]) ==
             {[debug: "true"], [], []}
  end

  test "parses string options from system variables" do
    System.put_env("DEBUG", "true")
    assert OptionParserPlus.parse([], strict: [debug: :string]) == {[debug: "true"], [], []}
    System.delete_env("DEBUG")
  end

  test "parses integer options from options list" do
    assert OptionParserPlus.parse(["--count", "3"], strict: [count: :integer]) ==
             {[count: 3], [], []}
  end

  test "parses integer options from system variables" do
    System.put_env("COUNT", "3")
    assert OptionParserPlus.parse([], strict: [count: :integer]) == {[count: 3], [], []}
    System.delete_env("COUNT")
  end

  test "parses float options from options list" do
    assert OptionParserPlus.parse(["--count", "3.5"], strict: [count: :float]) ==
             {[count: 3.5], [], []}
  end

  test "parses float options from system variables" do
    System.put_env("COUNT", "3.5")
    assert OptionParserPlus.parse([], strict: [count: :float]) == {[count: 3.5], [], []}
    System.delete_env("COUNT")
  end

  test "parses list options from options list" do
    assert OptionParserPlus.parse(["--users", "qw,er,ty"], strict: [users: :list]) ==
             {[users: ["qw", "er", "ty"]], [], []}
  end

  test "parses list options from system variables" do
    System.put_env("USERS", "qw,er,ty")

    assert OptionParserPlus.parse([], strict: [users: :list]) ==
             {[users: ["qw", "er", "ty"]], [], []}

    System.delete_env("USERS")
  end

  test "parses all possible options from options list" do
    assert OptionParserPlus.parse(
             ["--users", "qw,er,ty", "--count", "3.5", "--debug", "--val", "6"],
             strict: [users: :list, count: :float, debug: :boolean, val: :integer]
           ) ==
             {[{:users, ["qw", "er", "ty"]}, {:count, 3.5}, {:debug, true}, {:val, 6}], [], []}
  end

  test "parses all possible options from system variables" do
    System.put_env("USERS", "qw,er,ty")
    System.put_env("COUNT", "3.5")
    System.put_env("DEBUG", "true")
    System.put_env("VAL", "7")

    assert OptionParserPlus.parse([],
             strict: [users: :list, count: :float, debug: :boolean, val: :integer]
           ) ==
             {[{:val, 7}, {:debug, true}, {:count, 3.5}, {:users, ["qw", "er", "ty"]}], [], []}

    System.delete_env("USERS")
    System.delete_env("COUNT")
    System.delete_env("DEBUG")
    System.delete_env("VAL")
  end
end
