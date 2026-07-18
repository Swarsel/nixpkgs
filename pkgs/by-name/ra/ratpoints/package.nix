{
  lib,
  stdenv,
  fetchurl,
  gmp,
  texliveSmall,
  writableTmpDirAsHomeHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "ratpoints";
  version = "2.2.2";

  src = fetchurl {
    url = "https://www.mathe2.uni-bayreuth.de/stoll/programs/ratpoints-${finalAttrs.version}.tar.gz";
    hash = "sha256-2A4VIhkKHhIvey3i78Je+qyQf1XzdjXY2t3Q0Yqv/ZM=";
  };

  nativeBuildInputs = [
    (texliveSmall.withPackages (
      ps: with ps; [
        charter
        comment
        cyrillic
        preprint
        titlesec
        xypic
      ]
    ))
    writableTmpDirAsHomeHook
  ];

  buildInputs = [ gmp ];
  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  buildFlags = [
    "CCFLAGS1=${
      if stdenv.hostPlatform.avx512Support then
        "-DUSE_AVX512 -mavx512f"
      else if stdenv.hostPlatform.avx2Support then
        "-DUSE_AVX -mavx2"
      else if stdenv.hostPlatform.avxSupport then
        "-DUSE_AVX -mavx"
      else
        "-DUSE_SSE"
    }"
  ];

  preInstall = ''mkdir -p "$out"/{bin,share,lib,include}'';
  enableParallelBuilding = true;
  installFlags = [ "INSTALL_DIR=$(out)" ];

  meta = {
    description = "Program to find rational points on hyperelliptic curves";
    homepage = "http://www.mathe2.uni-bayreuth.de/stoll/programs/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.unix;
    mainProgram = "ratpoints";
  };
})
