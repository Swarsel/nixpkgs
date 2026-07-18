{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cccc";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "sarnold";
    repo = "cccc";
    tag = finalAttrs.version;
    sha256 = "sha256-5UgCz9zURD+LsMB3kLSdkS1zFOTCuU16hK253GFu9HU";
  };

  buildFlags = [
    "CCC=c++"
    "LD=c++"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-register " + lib.optionalString stdenv.cc.isGNU "-std=gnu17";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp cccc/cccc $out/bin/

    runHook postInstall
  '';

  hardeningDisable = [ "format" ];

  meta = {
    description = "C and C++ Code Counter";

    longDescription = ''
      CCCC is a tool which analyzes C++ and Java files and generates a report
      on various metrics of the code. Metrics supported include lines of code, McCabe's
      complexity and metrics proposed by Chidamber&Kemerer and Henry&Kafura.
    '';

    homepage = "https://github.com/sarnold/cccc";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ tbutter ];
    platforms = lib.platforms.unix;
    mainProgram = "cccc";
  };
})
