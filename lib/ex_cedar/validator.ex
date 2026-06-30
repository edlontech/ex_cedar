defmodule ExCedar.Validator do
  @moduledoc """
  Schema-based policy validation over compiled handles.

  Validates that every policy in a `PolicySet` is consistent with the given
  `Schema`. Findings (errors and warnings) are returned as plain data in a
  `ValidationResult` struct — they are not raised as exceptions.

  Only `:strict` validation mode is supported. Cedar's `:permissive` mode
  is experimental and not enabled.
  """

  alias ExCedar.{Error, Native, ValidationResult}
  alias ExCedar.ValidationResult.Finding

  @doc """
  Validates `policy_set` against `schema` and returns a `ValidationResult`.

  Options:
  - `:mode` — validation mode; only `:strict` is supported (default: `:strict`).

  Returns `{:ok, %ExCedar.ValidationResult{}}` on a successful call. Check
  `validated?` and the `errors`/`warnings` lists for findings.

  Returns `{:error, %ExCedar.Error.Invalid{}}` only for operational failures
  (e.g. non-reference handles passed as arguments), not for validation findings.

  Raises `ArgumentError` if an unsupported `mode` is given.
  """
  def validate(policy_set, schema, opts \\ [])

  def validate(policy_set, schema, opts)
      when is_reference(policy_set) and is_reference(schema) do
    do_validate(policy_set, schema, Keyword.get(opts, :mode, :strict))
  end

  def validate(_policy_set, _schema, _opts) do
    {:error,
     Error.to_class([%Error.Schema{message: "expected compiled policy set and schema handles"}])}
  end

  defp do_validate(policy_set, schema, :strict) do
    %{errors: raw_errors, warnings: raw_warnings} = Native.validate(policy_set, schema, :strict)

    errors = Enum.map(raw_errors, &struct(Finding, &1))
    warnings = Enum.map(raw_warnings, &struct(Finding, &1))

    {:ok, %ValidationResult{validated?: errors == [], errors: errors, warnings: warnings}}
  end

  defp do_validate(_policy_set, _schema, mode) do
    raise ArgumentError,
          "unsupported validation mode #{inspect(mode)}; only :strict is supported " <>
            "(permissive validation is experimental in Cedar and not enabled)"
  end
end
