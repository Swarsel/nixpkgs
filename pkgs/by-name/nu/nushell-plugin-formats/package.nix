{
  lib,
  stdenv,
  nix-update-script,
  nushell,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (nushell) version src cargoHash;
  pname = "nu_plugin_formats";
  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.cc.isClang [ rustPlatform.bindgenHook ];
  buildAndTestSubdir = "crates/nu_plugin_formats";

  passthru.updateScript = nix-update-script {
    # Skip the version check and only check the hash because we inherit version from nushell.
    extraArgs = [ "--version=skip" ];
  };

  meta = {
    description = "Formats plugin for Nushell";
    homepage = "https://github.com/nushell/nushell/tree/${finalAttrs.version}/crates/nu_plugin_formats";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      viraptor
    ];

    mainProgram = "nu_plugin_formats";
  };
})
