defmodule ExCedar.Validator do
  @moduledoc false

  alias ExCedar.{Error, Native, ValidationResult}
  alias ExCedar.ValidationResult.Finding

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
