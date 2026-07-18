{
  lib,
  stdenv,
  fetchurl,
  dos2unix,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bwbasic";
  version = "3.40";

  src = fetchurl {
    url = "mirror://sourceforge/project/bwbasic/bwbasic/version%20${finalAttrs.version}/bwbasic-${finalAttrs.version}.zip";
    hash = "sha256-tWiUIqCdBarhFDSX0iV55VxOEh7iuAbnOLSDuMAAog8=";
  };

  postPatch = ''
    dos2unix configure
    patchShebangs configure
    chmod +x configure
    substituteInPlace bwbasic.h \
      --replace-fail "extern int putenv (const char *buffer)" "extern int putenv (char *buffer)"
  '';

  nativeBuildInputs = [
    dos2unix
    unzip
  ];

  env.NIX_CFLAGS_COMPILE = "-std=c89";

  preInstall = ''
    mkdir -p $out/bin
  '';

  hardeningDisable = [ "format" ];
  sourceRoot = ".";

  meta = {
    description = "Bywater BASIC Interpreter";
    homepage = "https://sourceforge.net/projects/bwbasic/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ irenes ];
    platforms = lib.platforms.all;
    mainProgram = "bwbasic";
  };
})
