{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "emmylua_ls";
  version = "0.23.2";

  src = fetchFromGitHub {
    owner = "EmmyLuaLs";
    repo = "emmylua-analyzer-rust";
    tag = finalAttrs.version;
    hash = "sha256-xjKTYzkfFWKyQzg6I2aafKBGn7XjkE8CCQ9AP8ebu/I=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-tVmATUh35h19AsmMCrijJ0rdBHYU6uMj2PE1iiiuDCE=";
  # Needed to get openssl-sys to use pkg-config.
  env.OPENSSL_NO_VENDOR = 1;
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __structuredAttrs = true;
  buildAndTestSubdir = "crates/emmylua_ls";
  versionCheckProgram = "${placeholder "out"}/bin/emmylua_ls";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "EmmyLua Language Server";
    homepage = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust";
    changelog = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mrcjkb
    ];

    platforms = lib.platforms.all;
    mainProgram = "emmylua_ls";
  };
})
