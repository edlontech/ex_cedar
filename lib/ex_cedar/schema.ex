defmodule ExCedar.Schema do
  @moduledoc false

  alias ExCedar.{Error, Native}

  def compile(text) when is_binary(text) do
    wrap_nif(Native.schema_from_str(text))
  end

  def compile!(text) do
    Error.unwrap!(compile(text))
  end

  def from_json(json) when is_binary(json) do
    wrap_nif(Native.schema_from_json(json))
  end

  def from_json(term) when is_map(term) do
    json = term |> :json.encode() |> IO.iodata_to_binary()
    wrap_nif(Native.schema_from_json(json))
  end

  def from_json!(json) do
    Error.unwrap!(from_json(json))
  end

  defp wrap_nif({:ok, _} = ok), do: ok

  defp wrap_nif({:error, msg}) do
    {:error, Error.to_class([%Error.Schema{message: msg, details: nil}])}
  end
end
