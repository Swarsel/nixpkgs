{
  lib,
  emmylua-ls,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (emmylua-ls) version src cargoHash;
  pname = "emmylua_formatter";
  strictDeps = true;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  buildAndTestSubdir = "crates/emmylua_formatter";
  versionCheckProgram = "${placeholder "out"}/bin/luafmt";

  meta = {
    description = "Lua and EmmyLua formatter used by the EmmyLua Analyzer Rust workspace.";
    homepage = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust";
    changelog = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mrcjkb
    ];

    platforms = lib.platforms.all;
    mainProgram = "luafmt";
  };
})
