%Doctor.Config{
  ignore_modules: [
    # Internal NIF loader — intentionally @moduledoc false
    ExCedar.Native,
    # Internal Cedar JSON value encoder — intentionally @moduledoc false
    ExCedar.Value,
    # Splode-generated error class modules — no user-facing functions
    ExCedar.Error.Invalid,
    ExCedar.Error.Unknown,
    # Splode member error modules — message/1 is framework-generated
    ExCedar.Error.Parse,
    ExCedar.Error.Schema,
    ExCedar.Error.Entities,
    ExCedar.Error.Request,
    ExCedar.Error.Context,
    ExCedar.Error.TemplateLink,
    ExCedar.Error.Native
  ],
  min_module_doc_coverage: 100,
  min_module_spec_coverage: 0,
  min_overall_doc_coverage: 100,
  min_overall_moduledoc_coverage: 100,
  min_overall_spec_coverage: 0,
  raise: false,
  reporter: Doctor.Reporters.Full,
  struct_type_spec_required: true,
  umbrella: false,
  failed: false
}
