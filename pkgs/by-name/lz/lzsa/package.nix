{
  lib,
  stdenv,
  fetchFromGitHub,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "lzsa";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "emmanuel-marty";
    repo = "lzsa";
    rev = finalAttrs.version;
    hash = "sha256-XaPtMW9INv/wzMXvlyXgE3VfFJCY/5R/HFGhV3ZKvGs=";
  };

  makeFlags = [
    "CC=${stdenv.cc.targetPrefix}cc"
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 lzsa -t $out/bin/
    runHook postInstall
  '';

  meta = {
    description = "Byte-aligned, efficient lossless packer that is optimized for fast decompression on 8-bit micros";
    homepage = "https://github.com/emmanuel-marty/lzsa";
    license = with lib.licenses; [ cc0 ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "lzsa";
  };
})
