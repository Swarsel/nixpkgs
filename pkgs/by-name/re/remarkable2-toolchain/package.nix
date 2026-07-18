{
  lib,
  stdenv,
  fetchurl,
  file,
  libarchive,
  python3,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "remarkable2-toolchain";
  version = "3.1.2";

  src = fetchurl {
    url = "https://storage.googleapis.com/remarkable-codex-toolchain/codex-x86_64-cortexa7hf-neon-rm11x-toolchain-${finalAttrs.version}.sh";
    sha256 = "sha256-JKMDRbkvoxwHiTm/o4JdLn3Mm2Ld1LyxTnCCwvnxk4c=";
    executable = true;
  };

  nativeBuildInputs = [
    libarchive
    python3
    file
    which
  ];

  installPhase = ''
    mkdir -p $out
    ENVCLEANED=1 $src -y -d $out
  '';

  dontBuild = true;
  dontUnpack = true;

  meta = {
    description = "Toolchain for cross-compiling to reMarkable 2 tablets";
    homepage = "https://remarkable.engineering/";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ tadfisher ];
    platforms = [ "x86_64-linux" ];
  };
})
