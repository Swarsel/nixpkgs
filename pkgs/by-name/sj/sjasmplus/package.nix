{
  lib,
  stdenv,
  fetchFromGitHub,
  luabridge,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sjasmplus";
  version = "1.23.0";

  src = fetchFromGitHub {
    owner = "z00m128";
    repo = "sjasmplus";
    tag = "v${finalAttrs.version}";
    hash = "sha256-k3rEpHvasqEQP16EZVwtA4jwf0wZ1zUlQpkAzN7JCDI=";
  };

  buildInputs = [ luabridge ];

  buildFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
    "CXX=${stdenv.cc.targetPrefix}c++"
  ];

  installPhase = ''
    runHook preInstall

    install -D --mode=0755 sjasmplus $out/bin/sjasmplus

    runHook postInstall
  '';

  meta = {
    description = "Z80 assembly language cross compiler based on the SjASM source code by Sjoerd Mastijn";
    homepage = "https://z00m128.github.io/sjasmplus/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ electrified ];
    platforms = lib.platforms.all;
    mainProgram = "sjasmplus";
  };
})
