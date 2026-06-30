defmodule ExCedar.PolicySet do
  @moduledoc false

  alias ExCedar.{EntityUid, Error, Native}

  def compile(text) when is_binary(text) do
    :telemetry.span([:ex_cedar, :compile], %{}, fn ->
      result =
        with {:error, messages} <- Native.policy_set_from_str(text) do
          entries = Enum.map(messages, &%{message: &1, span: nil})
          {:error, Error.to_class([%Error.Parse{errors: entries}])}
        end

      {result, %{}}
    end)
  end

  def compile!(text) do
    Error.unwrap!(compile(text))
  end

  def from_file(path) do
    with {:ok, text} <- File.read(path), do: compile(text)
  end

  def link_template(policy_set, template_id, new_id, env) do
    principal =
      case Map.get(env, :principal) do
        nil -> nil
        uid -> EntityUid.to_string(uid)
      end

    resource =
      case Map.get(env, :resource) do
        nil -> nil
        uid -> EntityUid.to_string(uid)
      end

    with {:error, msg} <-
           Native.policy_set_link_template(policy_set, template_id, new_id, principal, resource) do
      {:error, Error.to_class([%Error.TemplateLink{message: msg}])}
    end
  end

  def policy_ids(policy_set) do
    Native.policy_set_policy_ids(policy_set)
  end

  def template_ids(policy_set) do
    Native.policy_set_template_ids(policy_set)
  end
end
