{
  lib,
  fetchCrate,
  makeBinaryWrapper,
  nix-update-script,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-psp";
  version = "0.2.8";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-Jud89nYJq4xZn2HudmSA82hOYwItrrTblhIfeqqIqm8=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  cargoHash = "sha256-oL2KbhpqvPhtN7hpAuR6a383pPKlW1XuXkoew0ZvPUo=";

  postInstall = ''
    wrapProgram "$out/bin/cargo-psp" \
      --prefix PATH : "$out/bin"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Cargo build wrapper for creating Sony PSP executables";
    homepage = "https://github.com/overdrivenpotato/rust-psp/tree/master/cargo-psp";
    changelog = "https://github.com/overdrivenpotato/rust-psp/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      griffi-gh
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "cargo-psp";
  };
})
