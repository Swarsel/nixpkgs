{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  aalib,
  alsa-lib,
  libcaca,
  libpulseaudio,
  libsndfile,
  libxext,
  libxxf86vm,
  ncurses,
  openssl,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zesarux";
  version = "13.0";

  src = fetchFromGitHub {
    owner = "chernandezba";
    repo = "zesarux";
    tag = "ZEsarUX-${finalAttrs.version}";
    hash = "sha256-clwYn43Xswdo11T+aX78K1Qat5BoGwH3ByCT4qaMl8A=";
  };

  postPatch = ''
    patchShebangs *.sh
  '';

  strictDeps = true;

  nativeBuildInputs = [
    which
  ];

  buildInputs = [
    SDL2
    aalib
    alsa-lib
    libxxf86vm
    libxext
    libcaca
    libpulseaudio
    libsndfile
    ncurses
    openssl
  ];

  configureFlags = [
    "--prefix=${placeholder "out"}"
    "--c-compiler ${stdenv.cc.targetPrefix}cc"
    "--enable-cpustats"
    "--enable-memptr"
    "--enable-sdl2"
    "--enable-ssl"
    "--enable-undoc-scfccf"
    "--enable-visualmem"
  ];

  installPhase = ''
    runHook preInstall

    ./generate_install_sh.sh
    patchShebangs ./install.sh
    ./install.sh

    runHook postInstall
  '';

  sourceRoot = "${finalAttrs.src.name}/src";

  meta = {
    description = "ZX Second-Emulator And Released for UniX";
    homepage = "https://github.com/chernandezba/zesarux";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "zesarux";
  };
})
