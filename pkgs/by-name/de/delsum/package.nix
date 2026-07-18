{
  lib,
  fetchFromGitHub,
  gf2x,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "delsum";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "8051Enthusiast";
    repo = "delsum";
    tag = "v${finalAttrs.version}";
    hash = "sha256-trCH2LIC3hjm3MMEoVGO2AY33eYTfn4N2mm2rOfUwt4=";
  };

  buildInputs = [
    gf2x
  ];

  cargoHash = "sha256-Flz7h2/i4WIGr8CgVjpbCGHUkkGKSiHw5wlOIo7uuXo=";

  meta = {
    description = "Reverse engineer's checksum toolbox";
    homepage = "https://github.com/8051Enthusiast/delsum";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ timschumi ];
    mainProgram = "delsum";
  };
})
