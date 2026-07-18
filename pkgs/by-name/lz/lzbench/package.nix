{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lzbench";
  version = "2.3";

  src = fetchFromGitHub {
    owner = "inikep";
    repo = "lzbench";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-/rRLD7lK8YGyx6dHxw5BPydf2YigZn/dF5NF2Q2Misg=";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp lzbench $out/bin
  '';

  enableParallelBuilding = true;

  meta = {
    inherit (finalAttrs.src.meta) homepage;
    description = "In-memory benchmark of open-source LZ77/LZSS/LZMA compressors";

    license = with lib.licenses; [
      gpl2Only
      gpl3Only
    ];

    maintainers = with lib.maintainers; [ videl ];
    platforms = lib.platforms.all;
    mainProgram = "lzbench";
  };
})
