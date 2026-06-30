defmodule ExCedar.PolicySet do
  @moduledoc false

  alias ExCedar.{Error, Native}

  def compile(text) when is_binary(text) do
    with {:error, messages} <- Native.policy_set_from_str(text) do
      entries = Enum.map(messages, &%{message: &1, span: nil})
      {:error, Error.to_class([%Error.Parse{errors: entries}])}
    end
  end

  def compile!(text) do
    Error.unwrap!(compile(text))
  end

  def from_file(path) do
    with {:ok, text} <- File.read(path), do: compile(text)
  end
end
