{
  lib,
  fetchFromCodeberg,
  nix-update-script,
  pcsclite,
  pkg-config,
  rsop,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rsop";
  version = "0.11.0";

  src = fetchFromCodeberg {
    owner = "heiko";
    repo = "rsop";
    rev = "rsop/v${finalAttrs.version}";
    hash = "sha256-vZW4L3hm2vRRoLcxU631jiNrbk+w0hDaL4VXIrtP2aY=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pcsclite ];
  cargoHash = "sha256-qrurMKwSs0w2D6KPto7tpsuLGuAJ9drKhdmIAbEaD9M=";

  passthru = {
    tests.version = testers.testVersion {
      command = "rsop version";
      package = rsop;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Stateless OpenPGP (SOP) based on rpgp";
    homepage = "https://codeberg.org/heiko/rsop";

    license = with lib.licenses; [
      mit
      apsl20
      cc0
    ];

    maintainers = with lib.maintainers; [ nikstur ];
    mainProgram = "rsop";
  };
})
