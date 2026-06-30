# Changelog

## [0.1.3](https://github.com/edlontech/ex_cedar/compare/ex_cedar-v0.1.2...ex_cedar-v0.1.3) (2026-06-30)


### Bug Fixes

* Fixes the base_url for rustler ([b2e42eb](https://github.com/edlontech/ex_cedar/commit/b2e42eb14c1b7a5c824ccacbdef19258651a70eb))

## [0.1.2](https://github.com/edlontech/ex_cedar/compare/ex_cedar-v0.1.1...ex_cedar-v0.1.2) (2026-06-30)


### Bug Fixes

* Fixed MUSL builds ([f3410e2](https://github.com/edlontech/ex_cedar/commit/f3410e2ca6ca943e6800bdd2570a07afa40c6240))

## [0.1.1](https://github.com/edlontech/ex_cedar/compare/ex_cedar-v0.1.0...ex_cedar-v0.1.1) (2026-06-30)


### Bug Fixes

* Fixed release-please build ([1b3626f](https://github.com/edlontech/ex_cedar/commit/1b3626f2936820c0bc9859b08116c9cae98a4758))

## [0.1.0](https://github.com/edlontech/ex_cedar/compare/ex_cedar-v0.1.0...ex_cedar-v0.1.0) (2026-06-30)


### Features

* **authz:** is_authorized over compiled handles with decision struct ([24a33aa](https://github.com/edlontech/ex_cedar/commit/24a33aa29e9fdb27e831cd2bf1440e126df5675f))
* **authz:** support schema-validated requests ([6cde070](https://github.com/edlontech/ex_cedar/commit/6cde0708da003553b6402e9a61ef10420badf825))
* **entities:** build entity store handle from structs or json ([3b10c08](https://github.com/edlontech/ex_cedar/commit/3b10c082810927d0c00be5017a1013e0b0e9759d))
* **entity-uid:** add EntityUid struct with parse and render ([f47c4a8](https://github.com/edlontech/ex_cedar/commit/f47c4a8cf8cc332267aac7cde98bcd592b4cec79))
* **error:** add splode-based error layer ([8fa2da8](https://github.com/edlontech/ex_cedar/commit/8fa2da8cc0311e59d858aeb5075f5fdf33d58f95))
* **native:** scaffold rust crate and rustler nif loader ([40bb32b](https://github.com/edlontech/ex_cedar/commit/40bb32bb16d5c3f82a6553810542a4ce2bf5a067))
* **packaging:** precompiled release pipeline and hex metadata ([08f3f79](https://github.com/edlontech/ex_cedar/commit/08f3f79f9e0aa1bd425801142366d28cb81164b0))
* **policy-set:** compile cedar policies to a reusable handle ([b7e25ea](https://github.com/edlontech/ex_cedar/commit/b7e25eaab7b88a9bc6c2a583975f2b6cd10b562e))
* **schema:** parse cedar schema to a reusable handle ([df8d6c4](https://github.com/edlontech/ex_cedar/commit/df8d6c4bc7b77db5b174ba94fd3c8a227a5bffe9))
* **structs:** add Entity, Context, Request with cedar encoders ([645fa08](https://github.com/edlontech/ex_cedar/commit/645fa08e25688ce190def29e749268be162697d5))
* **telemetry:** emit spans for compile and authorize ([380624d](https://github.com/edlontech/ex_cedar/commit/380624d184c83ffc9c6ec7c9bfe3b33cef52c492))
* **templates:** link policy templates and introspect policy sets ([2d3d57e](https://github.com/edlontech/ex_cedar/commit/2d3d57e1f4fbca6b1af1c4dd13efda9a57e9e78f))
* **validator:** validate policy sets against a schema ([4b0b274](https://github.com/edlontech/ex_cedar/commit/4b0b2744b7d0f42d850673ec5a465aa59cef09bf))
* **value:** add cedar json value encoder with extensions ([243f15e](https://github.com/edlontech/ex_cedar/commit/243f15e672351fb06e4d012f691cde52453f838a))


### Bug Fixes

* Fixed CI Release ([e38b74e](https://github.com/edlontech/ex_cedar/commit/e38b74eb512ef54da3801c7809432469c21a8f81))
