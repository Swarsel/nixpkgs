{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rar2hashcat";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "hashstation";
    repo = "rar2hashcat";
    rev = finalAttrs.version;
    hash = "sha256-GVh4Gyjn84xAwO7wKXYe2DPnpb8gnxGIMH5Szce+XpY=";
  };

  patches = [
    ./darwin-support.patch
  ];

  makeFlags = [
    "CC_LINUX=${stdenv.cc.targetPrefix}cc"
    "rar2hashcat"
  ];

  env.NIX_CFLAGS_COMPILE = lib.optionalString stdenv.cc.isClang "-Wno-error=implicit-function-declaration -Wno-error=int-conversion";

  installPhase = ''
    runHook preInstall

    install -D rar2hashcat $out/bin/rar2hashcat

    runHook postInstall
  '';

  meta = {
    description = "Processes input RAR files into a format suitable for use with hashcat";
    homepage = "https://github.com/hashstation/rar2hashcat";
    changelog = "https://github.com/hashstation/rar2hashcat/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ emilytrau ];
    platforms = lib.platforms.unix;
    mainProgram = "rar2hashcat";
  };
})
