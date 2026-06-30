# ExCedar

ExCedar is an Elixir library that wraps the [Cedar](https://www.cedarpolicy.com/) authorization
policy engine via a NIF built with [Rustler](https://github.com/rusterlium/rustler). It gives
Elixir applications a fast, idiomatic interface to Cedar — evaluating authorization decisions
against policies and entity stores — without requiring users to install a Rust toolchain, thanks
to precompiled NIF artifacts distributed with the package.

## Installation

Add `ex_cedar` to your dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_cedar, "~> 0.1"}
  ]
end
```

## Usage

### Authorize

```elixir
policy = """
permit(
  principal == User::"alice",
  action == Action::"view",
  resource == Document::"doc1"
);
"""

entities = [
  %ExCedar.Entity{
    uid: ExCedar.EntityUid.new("User", "alice"),
    attributes: %{},
    parents: []
  }
]

request = %ExCedar.Request{
  principal: ExCedar.EntityUid.new("User", "alice"),
  action: ExCedar.EntityUid.new("Action", "view"),
  resource: ExCedar.EntityUid.new("Document", "doc1"),
  context: %{}
}

{:ok, %ExCedar.Decision{decision: :allow}} = ExCedar.authorize(policy, entities, request)
```

For multiple requests against the same policy set, compile once and reuse the handles:

```elixir
{:ok, ps}   = ExCedar.PolicySet.compile(policy)
{:ok, ents} = ExCedar.Entities.from_list(entities)

{:ok, %ExCedar.Decision{decision: :allow}} =
  ExCedar.Authorizer.authorize(ps, ents, request)
```

### Validate

Use `ExCedar.Schema` and `ExCedar.Validator` to check that your policies are consistent
with your schema before deploying them:

```elixir
schema_text = """
entity User;
entity Document;
action "view" appliesTo {
  principal: [User],
  resource: [Document],
  context: {}
};
"""

{:ok, schema} = ExCedar.Schema.compile(schema_text)
{:ok, ps}     = ExCedar.PolicySet.compile(policy)

{:ok, %ExCedar.ValidationResult{validated?: true, errors: [], warnings: _}} =
  ExCedar.Validator.validate(ps, schema)
```

You can also pass a compiled schema to `authorize` to enable type-aware evaluation and
request shape validation:

```elixir
ExCedar.Authorizer.authorize(ps, ents, request, schema: schema)
# or via the one-shot facade:
ExCedar.authorize(policy, entities, request, schema: schema_text)
```

### Policy templates

Cedar supports template policies with `?principal` and `?resource` slots. Use
`ExCedar.PolicySet.link_template/4` to bind slots and get a new, immutable handle.

Cedar assigns ids (`"policy0"`, `"policy1"`, ...) when parsing policy text, so
discover the template id with `template_ids/1` rather than hardcoding it:

```elixir
template = "permit(principal == ?principal, action, resource);"

{:ok, ps} = ExCedar.PolicySet.compile(template)
[template_id] = ExCedar.PolicySet.template_ids(ps)

principal = ExCedar.EntityUid.new("User", "alice")
{:ok, ps2} = ExCedar.PolicySet.link_template(ps, template_id, "alice_policy", %{principal: principal})

# ps is unchanged; ps2 includes the linked policy
ExCedar.PolicySet.policy_ids(ps2)
# => ["alice_policy"]
```

## Handles

`ExCedar.PolicySet.compile/1`, `ExCedar.Schema.compile/1`, and `ExCedar.Entities.from_list/1`
return opaque NIF resource handles (`ResourceArc`). These handles are:

- **Immutable** — operations that "modify" a policy set (like `link_template/4`) return a
  new handle; the original is unchanged.
- **Thread-safe** — safe to share across processes or store in ETS/module attributes.
- **Not persistent** — handles do not survive a node restart. Recompile from source on
  boot, for example in `Application.start/2` or a supervised startup task.

## Telemetry

ExCedar emits `:telemetry` span events around native operations. See
`ExCedar.Telemetry` for the full event contract.

Events:

- `[:ex_cedar, :authorize, :start | :stop | :exception]`
- `[:ex_cedar, :compile, :start | :stop | :exception]`

## Precompiled NIFs

By default, ExCedar downloads a precompiled NIF for your platform at compile time — no Rust
toolchain required. To force a source build (for example, when developing ExCedar itself or
targeting an unsupported platform), set `EX_CEDAR_BUILD=1` before compiling:

```sh
EX_CEDAR_BUILD=1 mix compile
```

Documentation is available at <https://hexdocs.pm/ex_cedar>.
