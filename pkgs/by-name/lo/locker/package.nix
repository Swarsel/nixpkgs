{
  lib,
  fetchFromGitHub,
  nix-update-script,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "locker";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "tgirlcloud";
    repo = "locker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rVW2OcRG2h5G46UdRLYeZ5A0Gmca2fj5rRbZzMeDqqc=";
  };

  cargoHash = "sha256-gfhOOgZ8wkqbcghcCGCBMtImLfZazR2Dg/FgnjbofAg=";
  __structuredAttrs = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "A linter for your flake.lock file";
    homepage = "https://github.com/tgirlcloud/locker";
    license = lib.licenses.eupl12;
    maintainers = with lib.maintainers; [ isabelroses ];
    mainProgram = "locker";
  };
})
