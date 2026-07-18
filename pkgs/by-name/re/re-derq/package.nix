{
  lib,
  fetchFromCodeberg,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "re-derq";
  version = "1.0.1";

  src = fetchFromCodeberg {
    owner = "viraptor";
    repo = "re-derq";
    tag = finalAttrs.version;
    hash = "sha256-dnkxHEuFCn/QVMdTNhWtv5fh54Gald0YQCO0/LoQtCI=";
  };

  cargoHash = "sha256-KnH8jJb2rLn2LAgno+QbBg5K5NQErlvGDbhxEthwryM=";
  __structuredAttrs = true;

  meta = {
    description = "Open reimplementation of Apple's derq";
    homepage = "https://codeberg.org/viraptor/re-derq";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ viraptor ];
    platforms = lib.platforms.unix;
    mainProgram = "derq";
  };
})
