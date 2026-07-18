{
  lib,
  stdenv,
  fetchurl,
  SDL,
  alsa-lib,
  gcc-unwrapped,
  libice,
  libsm,
  libx11,
  libxext,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "atari++";
  version = "1.85";

  src = fetchurl {
    url = "http://www.xl-project.com/download/atari++_${finalAttrs.version}.tar.gz";
    hash = "sha256-LbGTVUs1XXR+QfDhCxX9UMkQ3bnk4z0ckl94Cwwe9IQ=";
  };

  buildInputs = [
    SDL
    alsa-lib
    gcc-unwrapped
    libice
    libsm
    libx11
    libxext
  ];

  postFixup = ''
    patchelf \
      --set-rpath ${lib.makeLibraryPath finalAttrs.buildInputs} \
      "$out/bin/atari++"
  '';

  meta = {
    description = "Enhanced, cycle-accurated Atari emulator";

    longDescription = ''
      The Atari++ Emulator is a Unix based emulator of the Atari eight bit
      computers, namely the Atari 400 and 800, the Atari 400XL, 800XL and 130XE,
      and the Atari 5200 game console. The emulator is auto-configurable and
      will compile on a variety of systems (Linux, Solaris, Irix).
    '';

    homepage = "http://www.xl-project.com/";
    license = with lib.licenses; [ gpl2Plus ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "atari++";
  };
})
