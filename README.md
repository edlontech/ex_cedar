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
    {:ex_cedar, "~> 0.1.0"}
  ]
end
```

## Usage

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

## Precompiled NIFs

By default, ExCedar downloads a precompiled NIF for your platform at compile time — no Rust
toolchain required. To force a source build (for example, when developing ExCedar itself or
targeting an unsupported platform), set `EX_CEDAR_BUILD=1` before compiling:

```sh
EX_CEDAR_BUILD=1 mix compile
```

Documentation is available at <https://hexdocs.pm/ex_cedar>.
