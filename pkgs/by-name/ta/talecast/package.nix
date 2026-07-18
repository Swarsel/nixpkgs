{
  lib,
  fetchCrate,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  talecast,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "talecast";
  version = "0.1.39";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-RwB+X+i3CEcTyKac81he9/cT2aQ4M7AqgqSDBEvhFJU=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-mRoFg1UUPCKWiPxZg+8o2+2K6R+88RI/pdO8OLM4jFk=";

  passthru = {
    tests.version = testers.testVersion { package = talecast; };
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple CLI podcatcher";
    homepage = "https://github.com/TBS1996/TaleCast";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      confusedalex
      getchoo
    ];

    mainProgram = "talecast";
  };
})
