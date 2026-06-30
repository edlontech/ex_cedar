defmodule ExCedar.Telemetry do
  @moduledoc """
  Telemetry event contract for ExCedar.

  ExCedar emits telemetry span events around its two native operations via
  `:telemetry.span/3`. Each span produces a `:start` event at entry and either
  a `:stop` event on normal return or an `:exception` event when the span
  function raises.

  All time values are in Erlang native time units. Convert with
  `:erlang.convert_time_unit(value, :native, :microsecond)`.

  ## Events

  ### `[:ex_cedar, :authorize, :start | :stop | :exception]`

  Emitted by `ExCedar.Authorizer.authorize/4` around the native authorization
  call.

  **Measurements**

  | Key              | `:start` | `:stop` | `:exception` |
  |------------------|----------|---------|--------------|
  | `:monotonic_time`| yes      | yes     | yes          |
  | `:system_time`   | yes      | —       | —            |
  | `:duration`      | —        | yes     | yes          |

  **Metadata**

  - `:start` — `%{}` (no context available before the call)
  - `:stop` on `{:ok, %Decision{}}` — `%{decision: :allow | :deny, determining_policy_count: non_neg_integer()}`
  - `:stop` on `{:error, _}` — `%{error: true}`
  - `:exception` — `%{kind: :error | :throw | :exit, reason: term(), stacktrace: list()}`

  Note: `policy_count` and `entity_count` are not emitted because handles are
  opaque at authorization time. Those fields will be added when introspection
  NIFs are available (planned for v0.3).

  ### `[:ex_cedar, :compile, :start | :stop | :exception]`

  Emitted by `ExCedar.PolicySet.compile/1` around the native policy-set parse.

  **Measurements** — same keys as `:authorize` above.

  **Metadata**

  - `:start` — `%{}`
  - `:stop` — `%{}` (no meaningful counters available without introspection)
  - `:exception` — `%{kind: :error | :throw | :exit, reason: term(), stacktrace: list()}`

  Note: a compile failure (bad policy text) returns `{:error, _}` and flows
  through `:stop`, not `:exception`. The `:exception` event is only emitted on
  an unexpected raise inside the span.

  ## Attaching handlers

  Use `:telemetry.attach/4` or `:telemetry.attach_many/4` in your application
  start, or `:telemetry_test.attach_event_handlers/2` in tests:

      events = [
        [:ex_cedar, :authorize, :stop],
        [:ex_cedar, :compile, :stop]
      ]
      :telemetry.attach_many("my-handler", events, &MyHandler.handle/4, nil)
  """
end
