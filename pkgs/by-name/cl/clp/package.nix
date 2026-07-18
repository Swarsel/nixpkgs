{
  lib,
  stdenv,
  fetchFromGitHub,
  coin-utils,
  osi,
  pkg-config,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "clp";
  version = "1.17.10";

  src = fetchFromGitHub {
    owner = "coin-or";
    repo = "Clp";
    rev = "releases/${finalAttrs.version}";
    hash = "sha256-9IlBT6o1aHAaYw2/39XrUis72P9fesmG3B6i/e+v3mM=";
  };

  nativeBuildInputs = [ pkg-config ];

  propagatedBuildInputs = [
    zlib
    coin-utils
    osi
  ];

  doCheck = true;

  meta = {
    description = "Open-source linear programming solver written in C++";
    homepage = "https://github.com/coin-or/Clp";
    license = lib.licenses.epl20;
    maintainers = [ lib.maintainers.vbgl ];
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
    mainProgram = "clp";
  };
})
