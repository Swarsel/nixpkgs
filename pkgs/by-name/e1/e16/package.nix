{
  lib,
  stdenv,
  fetchurl,
  freetype,
  gitUpdater,
  imlib2,
  libpulseaudio,
  libsm,
  libsndfile,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxft,
  libxinerama,
  libxrandr,
  pango,
  perl,
  pkg-config,
  python3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "e16";
  version = "1.0.31";

  src = fetchurl {
    url = "mirror://sourceforge/enlightenment/e16-${finalAttrs.version}.tar.xz";
    hash = "sha256-ZQTsIy/BiO/xUiCu+bc2n406F0unAinxyYLjVRfUSiQ=";
  };

  postPatch = ''
    substituteInPlace scripts/e_gen_menu --replace "/usr/local:" "/run/current-system/sw:/usr/local:"
    substituteInPlace scripts/e_gen_menu --replace "'/opt'" "'/opt', '/run/current-system/sw'"
    substituteInPlace scripts/e_gen_menu --replace "'/.local'" "'/.nix-profile', '/.local'"
  '';

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    freetype
    imlib2
    libsm
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxft
    libxinerama
    libxrandr
    libpulseaudio
    libsndfile
    pango
    perl
    python3
  ];

  passthru.updateScript = gitUpdater {
    rev-prefix = "v";
    url = "https://git.enlightenment.org/e16/e16";
  };

  meta = {
    description = "Enlightenment DR16 window manager";
    homepage = "https://www.enlightenment.org/e16";
    license = lib.licenses.bsd2;
    maintainers = [ lib.maintainers.romildo ];
    platforms = lib.platforms.linux;
  };
})
