{
  lib,
  stdenv,
  fetchCrate,
  pkg-config,
  rustPlatform,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "elf2uf2-rs";
  version = "2.2.0";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-e0i8ecjfNZxQgX5kDU1T8yAGUl4J7mbgG+ueBFsyTNA=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = lib.optional stdenv.hostPlatform.isLinux udev;
  cargoHash = "sha256-+oByDYfC5yA4xzJdTAoji1S0LDc4w+pGhFPFHBgeL8A=";

  meta = {
    description = "Convert ELF files to UF2 for USB Flashing Bootloaders";
    homepage = "https://github.com/JoNil/elf2uf2-rs";
    license = with lib.licenses; [ bsd0 ];

    maintainers = with lib.maintainers; [
      polygon
      moni
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "elf2uf2-rs";
  };
})
