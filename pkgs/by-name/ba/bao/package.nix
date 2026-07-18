{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "bao";
  version = "0.13.1";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-8h5otpu3z2Hgy0jMCITJNr8Q4iVdlR5Lea2X+WuenWs=";
    pname = "${finalAttrs.pname}_bin";
  };

  cargoHash = "sha256-B0wvJTcIRJxBU0G1DONnKeQYrmsmMIorhTLc73o4/kE=";

  meta = {
    description = "Implementation of BLAKE3 verified streaming";
    homepage = "https://github.com/oconnor663/bao";

    license = with lib.licenses; [
      cc0
      asl20
    ];

    maintainers = with lib.maintainers; [ amarshall ];
    mainProgram = "bao";
  };
})
