{
  lib,
  emmylua-ls,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  inherit (emmylua-ls) version src cargoHash;
  pname = "emmylua_check";
  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  # Needed to get openssl-sys to use pkg-config.
  env.OPENSSL_NO_VENDOR = 1;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  buildAndTestSubdir = "crates/emmylua_check";
  versionCheckProgram = "${placeholder "out"}/bin/emmylua_check";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Comprehensive Lua static analysis tool for code quality assurance";
    homepage = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust";
    changelog = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mrcjkb
    ];

    platforms = lib.platforms.all;
    mainProgram = "emmylua_check";
  };
})
