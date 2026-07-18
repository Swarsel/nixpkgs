{
  lib,
  fetchCrate,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "0x";
  version = "0.1.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-im9F0MQYddCcBthSldeQ6T0BIswhBSGc/LKUlJg/754=";
    pname = "ohx";
  };

  cargoHash = "sha256-TCpJz/ZIOFiEvjQzrSnUASPOHbqD8GYy3IpozFGat/g=";

  meta = {
    description = "Colorful, configurable xxd";
    homepage = "https://github.com/mcy/0x";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "0x";
  };
})
