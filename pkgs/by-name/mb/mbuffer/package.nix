{
  lib,
  stdenv,
  fetchurl,
  openssl,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mbuffer";
  version = "20260511";

  src = fetchurl {
    url = "https://www.maier-komor.de/software/mbuffer/mbuffer-${finalAttrs.version}.tgz";
    sha256 = "sha256-E7qzbzlAj3oI+zaJEykK0PEXyTS6tgIJThj8wSPsV4M=";
  };

  outputs = [
    "out"
    "man"
  ];

  strictDeps = true;

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    openssl
  ];

  doCheck = true;

  nativeCheckInputs = [
    openssl
  ];

  __darwinAllowLocalNetworking = true;

  meta = {
    description = "Tool for buffering data streams with a large set of unique features";
    homepage = "https://www.maier-komor.de/mbuffer.html";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    mainProgram = "mbuffer";
  };
})
