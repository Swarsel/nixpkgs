{
  lib,
  stdenv,
  curl,
  nix-update-script,
  nushell,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (nushell) version src cargoHash;
  pname = "nu_plugin_query";
  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.cc.isClang [ rustPlatform.bindgenHook ];

  buildInputs = [
    openssl
    curl
  ];

  buildAndTestSubdir = "crates/nu_plugin_query";

  passthru.updateScript = nix-update-script {
    # Skip the version check and only check the hash because we inherit version from nushell.
    extraArgs = [ "--version=skip" ];
  };

  meta = {
    description = "Nushell plugin to query JSON, XML, and various web data";
    homepage = "https://github.com/nushell/nushell/tree/${finalAttrs.version}/crates/nu_plugin_query";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      happysalada
    ];

    mainProgram = "nu_plugin_query";
  };
})
