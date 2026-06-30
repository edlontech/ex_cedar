defmodule ExCedar.PolicySet do
  @moduledoc """
  Compiled Cedar policy set handle.

  `compile/1` parses Cedar policy DSL text and returns an opaque reference
  backed by a `ResourceArc<PolicySet>`. The handle is immutable, thread-safe,
  and can be shared across processes or stored in ETS. It does **not** survive
  a node restart; recompile from source on boot (e.g. in a supervised start
  task or `Application.start/2`).

  Use `link_template/4` to instantiate a template policy and get a new handle
  with the linked policy included.
  """

  alias ExCedar.{EntityUid, Error, Native}

  @doc """
  Parses Cedar policy text and returns a compiled handle.

      iex> {:ok, ps} = ExCedar.PolicySet.compile("permit(principal, action, resource);")
      iex> is_reference(ps)
      true

  Returns `{:error, %ExCedar.Error.Invalid{}}` if the policy text has syntax
  errors. The error's `errors` list contains `%ExCedar.Error.Parse{}` structs
  with Cedar's parse messages.
  """
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

  @doc "Like `compile/1` but raises an `ExCedar.Error` exception on failure."
  def compile!(text) do
    Error.unwrap!(compile(text))
  end

  @doc """
  Reads policy text from `path` and compiles it. Returns the same tuple
  shapes as `compile/1`, or `{:error, reason}` if the file cannot be read.
  """
  def from_file(path) do
    with {:ok, text} <- File.read(path), do: compile(text)
  end

  @doc """
  Instantiates template `template_id` with the given principal/resource UIDs
  and returns a **new** `PolicySet` handle that includes the linked policy.

  The original handle is unchanged. `env` is a map with optional `:principal`
  and `:resource` keys, each an `ExCedar.EntityUid`.

  Cedar auto-assigns IDs like `"policy0"` when parsing policy text without an
  explicit `@id()` annotation.

      iex> {:ok, ps} = ExCedar.PolicySet.compile("permit(principal == ?principal, action, resource);")
      iex> principal = ExCedar.EntityUid.new("User", "alice")
      iex> {:ok, ps2} = ExCedar.PolicySet.link_template(ps, "policy0", "alice_policy", %{principal: principal})
      iex> is_reference(ps2)
      true

  Returns `{:error, %ExCedar.Error.Invalid{}}` if the template ID does not
  exist or the slot environment is malformed.
  """
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

  @doc "Returns the list of static policy IDs in the compiled policy set."
  def policy_ids(policy_set) do
    Native.policy_set_policy_ids(policy_set)
  end

  @doc "Returns the list of template IDs in the compiled policy set."
  def template_ids(policy_set) do
    Native.policy_set_template_ids(policy_set)
  end
end
