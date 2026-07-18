{
  lib,
  buildBatExtrasPkg,
  clang-tools,
  prettier,
  rustfmt,
  shfmt,
  withClangTools ? true,
  withPrettier ? true,
  withRustFmt ? true,
  withShFmt ? true,
}:
buildBatExtrasPkg {
  dependencies =
    lib.optional withShFmt shfmt
    ++ lib.optional withPrettier prettier
    ++ lib.optional withClangTools clang-tools
    ++ lib.optional withRustFmt rustfmt;

  name = "prettybat";
  meta.description = "Pretty-print source code and highlight it with bat";
}
