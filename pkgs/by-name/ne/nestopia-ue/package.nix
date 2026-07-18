{
  lib,
  stdenv,
  fetchFromGitHub,
  SDL2,
  alsa-lib,
  autoconf-archive,
  autoreconfHook,
  fltk,
  libGL,
  libGLU,
  libao,
  libarchive,
  libepoxy,
  libsamplerate,
  makeWrapper,
  pkg-config,
  unzip,
  wrapGAppsHook3,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nestopia";
  version = "1.53.2";

  src = fetchFromGitHub {
    owner = "0ldsk00l";
    repo = "nestopia";
    rev = finalAttrs.version;
    hash = "sha256-sKemwbmEr637KL951wsmDxLFDvWh+0K+exdDd0+Iq1c=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    SDL2
    autoconf-archive
    autoreconfHook
    fltk
    pkg-config
    makeWrapper
    wrapGAppsHook3
    unzip
  ];

  buildInputs = [
    SDL2
    alsa-lib
    fltk
    libepoxy

    libGLU
    libGL
    libarchive
    libao
    xdg-utils
    libsamplerate
  ];

  preInstall = ''
    mkdir -p $out/{bin,share/nestopia}
  '';

  preFixup = ''
    for f in $out/bin/*; do
      wrapProgram $f \
        --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH:$out/share"
    done
  '';

  meta = {
    description = "Cross-platform Nestopia emulator core with a GUI";
    homepage = "http://0ldsk00l.ca/nestopia/";
    changelog = "https://raw.githubusercontent.com/0ldsk00l/nestopia/${finalAttrs.src.rev}/ChangeLog";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "nestopia";
  };
})
