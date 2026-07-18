{
  lib,
  fetchFromGitHub,
  libgit2,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "intelli-shell";
  version = "3.4.5";

  src = fetchFromGitHub {
    owner = "lasantosr";
    repo = "intelli-shell";
    rev = "v${finalAttrs.version}";
    hash = "sha256-jC5hvyefEEU8odiPaUWtWm8o2oHyS7ZOw4nJdvylb0U=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    sqlite
    zlib
  ];

  cargoHash = "sha256-g/sJJiwUl+N4ryFXhrbSIaOl0zzXKbehGyxTNamtua8=";

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  buildFeatures = [
    "extra-features"
  ];

  buildNoDefaultFeatures = true;

  meta = {
    description = "Like IntelliSense, but for shells";
    homepage = "https://github.com/lasantosr/intelli-shell";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lasantosr ];
    mainProgram = "intelli-shell";
  };
})
