{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  isa-l,
  pkg-config,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "strobealign";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "ksahlin";
    repo = "strobealign";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ah21ptyfZbgdJrtCCftYhGh1hfcJ9JpXNsXUp8pZDJw=";
  };

  patches = [
    ./include-cstdint.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    zlib
    isa-l
  ];

  meta = {
    description = "Read aligner for short reads";
    homepage = "https://github.com/ksahlin/strobealign";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jbedo ];
    platforms = lib.platforms.unix;
    mainProgram = "strobealign";
  };
})
