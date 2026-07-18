{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoc,
  jansson,
  meson,
  ninja,
  openssl,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "jose";
  version = "14";

  src = fetchFromGitHub {
    owner = "latchset";
    repo = "jose";
    rev = "v${finalAttrs.version}";
    hash = "sha256-rMNPJaCtVpbwIkMQzBNpmRct6S/NelTwjmsuB0RP6R8=";
  };

  outputs = [
    "out"
    "dev"
    "man"
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    asciidoc
  ];

  buildInputs = [
    zlib
    jansson
    openssl
  ];

  enableParallelBuilding = true;

  meta = {
    description = "C-language implementation of Javascript Object Signing and Encryption";
    homepage = "https://github.com/latchset/jose";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "jose";
    # The last successful Darwin Hydra build was in 2024
    broken = stdenv.hostPlatform.isDarwin;
  };
})
