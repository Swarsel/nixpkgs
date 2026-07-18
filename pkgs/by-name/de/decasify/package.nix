{
  lib,
  stdenv,
  fetchurl,
  cargo,
  jq,
  pkg-config,
  rustPlatform,
  rustc,
  # nativeBuildInputs
  zstd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "decasify";
  version = "0.11.3";

  src = fetchurl {
    url = "https://github.com/alerque/decasify/releases/download/v${finalAttrs.version}/decasify-${finalAttrs.version}.tar.zst";
    hash = "sha256-JATJ8cFjtCkK65NpTTrUkYHAo4nDrqftarqyJInRTpM=";
  };

  outputs = [
    "out"
    "doc"
    "man"
    "dev"
  ];

  nativeBuildInputs = [
    zstd
    pkg-config
    jq
    cargo
    rustc
    rustPlatform.cargoSetupHook
  ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    nativeBuildInputs = [ zstd ];
    dontConfigure = true;
    hash = "sha256-hXU9Yw9rGQDkNnwy63LYPIrreOO2P/f8jVaPnVOhrWI=";
  };

  enableParallelBuilding = true;

  meta = {
    description = "Utility to change the case of prose strings following natural language style guides";

    longDescription = ''
      A CLI utility to cast strings to title-case (and other cases) according
      to locale specific style guides including Turkish support.
    '';

    homepage = "https://github.com/alerque/decasify";
    changelog = "https://github.com/alerque/decasify/raw/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      alerque
    ];

    platforms = lib.platforms.unix;
    mainProgram = "decasify";
  };
})
