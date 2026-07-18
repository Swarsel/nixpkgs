{
  lib,
  stdenv,
  nix-update-script,
  nushell,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (nushell) version src cargoHash;
  pname = "nu_plugin_gstat";
  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.cc.isClang [ rustPlatform.bindgenHook ];
  buildInputs = [ openssl ];
  buildAndTestSubdir = "crates/nu_plugin_gstat";

  passthru.updateScript = nix-update-script {
    # Skip the version check and only check the hash because we inherit version from nushell.
    extraArgs = [ "--version=skip" ];
  };

  meta = {
    description = "Git status plugin for Nushell";
    homepage = "https://github.com/nushell/nushell/tree/${finalAttrs.version}/crates/nu_plugin_gstat";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mrkkrp
    ];

    mainProgram = "nu_plugin_gstat";
  };
})
