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
  pname = "nu_plugin_polars";
  nativeBuildInputs = [ pkg-config ] ++ lib.optionals stdenv.cc.isClang [ rustPlatform.bindgenHook ];
  buildInputs = [ openssl ];

  checkFlags = [
    "--skip=dataframe::command::core::to_repr::test::test_examples"
  ];

  buildAndTestSubdir = "crates/nu_plugin_polars";

  passthru.updateScript = nix-update-script {
    # Skip the version check and only check the hash because we inherit version from nushell.
    extraArgs = [ "--version=skip" ];
  };

  meta = {
    description = "Nushell dataframe plugin commands based on polars";
    homepage = "https://github.com/nushell/nushell/tree/${finalAttrs.version}/crates/nu_plugin_polars";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ joaquintrinanes ];
    mainProgram = "nu_plugin_polars";
  };
})
