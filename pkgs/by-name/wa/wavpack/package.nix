{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gettext,
  libiconv,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wavpack";
  version = "5.9.0";

  src = fetchFromGitHub {
    owner = "dbry";
    repo = "WavPack";
    rev = finalAttrs.version;
    hash = "sha256-bG2RGYoJyNX2NObccA3TF1O0Lj/R531hlm/CiNCOCmM=";
  };

  outputs = [
    "out"
    "dev"
    "doc"
    "man"
  ];

  nativeBuildInputs = [
    autoreconfHook
    gettext
  ];

  buildInputs = [ libiconv ];
  enableParallelBuilding = true;

  meta = {
    description = "Hybrid audio compression format";
    homepage = "https://www.wavpack.com/";
    changelog = "https://github.com/dbry/WavPack/releases/tag/${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
