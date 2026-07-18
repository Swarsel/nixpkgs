{
  lib,
  fetchCrate,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "geoclock";
  version = "1.0.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-s23e9shdEnCnyr/LI0MioTW3vkoDZPIwWwJhyFUO7o4=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-7mApZj3Ksy8Av0W+0+UZQCkH281bSBd4xo8/7JowmHs=";
  cargoDepsName = "geoclock";

  meta = {
    description = "Displays time as calculated by your longitude";
    homepage = "https://github.com/FGRCL/geoclock";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.fgrcl ];
  };
})
