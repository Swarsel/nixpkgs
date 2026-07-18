{
  lib,
  stdenv,
  fetchurl,
  SDL,
  SDL_ttf,
  alsa-lib,
  cdparanoia,
  dejavu_fonts,
  ffmpeg,
  jack2,
  libmpg123,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xwax";
  version = "1.9";

  src = fetchurl {
    url = "https://xwax.org/releases/xwax-${finalAttrs.version}.tar.gz";
    hash = "sha256-m+2PoUMYKBhlA2H0kld1W/iR8UMWEGaqp7yoxszp9jI=";
  };

  postPatch = ''
    # When cross-compiling sdl-config will not be available in $PATH,
    # so we must provide the full path.
    substituteInPlace Makefile \
      --replace-fail sdl-config "${lib.getExe' (lib.getDev SDL) "sdl-config"}"

    # font loading in xwax is relying on a hardcoded list of paths,
    # therefore we patch interface.c to also look up in the dejavu_fonts nix store path
    substituteInPlace interface.c \
      --replace-fail "/usr/X11R6/lib/X11/fonts/TTF" "${dejavu_fonts.outPath}/share/fonts/truetype/"

    # make paths to executed binaries hermetic:
    substituteInPlace import \
      --replace-fail "exec cdparanoia" "exec ${lib.getExe cdparanoia}" \
      --replace-fail "exec ffmpeg" "exec ${lib.getExe ffmpeg}"
  '';

  buildInputs = [
    # sdl
    SDL
    SDL_ttf

    alsa-lib

    # audio server
    jack2

    # audio decoder
    libmpg123
    ffmpeg
    cdparanoia

    # fonts
    dejavu_fonts
  ];

  configureFlags = [
    "--enable-alsa"
    "--enable-jack"
  ];

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;
  versionCheckProgramArg = "-h";

  meta = {
    description = "Digital vinyl on Linux";
    homepage = "https://xwax.org";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ obsoleszenz ];
    platforms = lib.platforms.linux;
    mainProgram = "xwax";
  };
})
