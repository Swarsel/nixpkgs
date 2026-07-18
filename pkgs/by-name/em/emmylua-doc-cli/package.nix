{
  lib,
  emmylua-ls,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (emmylua-ls) version src cargoHash;
  pname = "emmylua_doc_cli";
  strictDeps = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  buildAndTestSubdir = "crates/emmylua_doc_cli";
  versionCheckProgram = "${placeholder "out"}/bin/emmylua_doc_cli";

  meta = {
    description = "Professional documentation generator creating beautiful, searchable API docs from your Lua code and annotations.";
    homepage = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust";
    changelog = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mrcjkb
    ];

    platforms = lib.platforms.all;
    mainProgram = "emmylua_doc_cli";
  };
})
