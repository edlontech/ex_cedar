defmodule ExCedar.Error do
  @moduledoc """
  Top-level Splode error module for ExCedar.

  Groups errors into two classes:
  - `:invalid` — bad user input (parse failures, schema issues, etc.)
  - `:unknown` — unexpected NIF or decode failures
  """

  use Splode,
    error_classes: [
      invalid: ExCedar.Error.Invalid,
      unknown: ExCedar.Error.Unknown
    ],
    unknown_error: ExCedar.Error.Native
end
