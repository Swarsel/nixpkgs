{
  lib,
  stdenv,
  aubio,
  autoreconfHook,
  evince,
  fetchDebianPatch,
  fetchgit,
  fftw,
  fluidsynth,
  gettext,
  glib,
  gtk-doc,
  gtk3,
  gtksourceview,
  guile,
  intltool,
  libjack2,
  librsvg,
  libsndfile,
  libxml2,
  lilypond,
  pkg-config,
  portaudio,
  portmidi,
  rubberband,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "denemo";
  version = "2.6.49";

  src = fetchgit {
    url = "https://git.savannah.gnu.org/git/denemo.git";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TUdaGOChqwK3fAmdaP9Lg2FGrEWF0yjwqsRXK7h/83Y=";
  };

  patches = [
    (fetchDebianPatch {
      pname = "denemo";
      version = "2.6.49";
      debianRevision = "0.2";
      hash = "sha256-l1eXjQieH5ySqwaTJAE8lUq/FsB//cl02Wgt0TRQBMo=";
      patch = "0002-Prevent-incompatible-pointer-types.patch";
    })
    (fetchDebianPatch {
      pname = "denemo";
      version = "2.6.49";
      debianRevision = "0.2";
      hash = "sha256-H3hRmAPazYRkwQI97vNR9kpV0lYpIiAXyMfrnJl+lNo=";
      patch = "0013-Fix-FTBFS-with-GCC-14.patch";
    })
    (fetchDebianPatch {
      pname = "denemo";
      version = "2.6.49";
      debianRevision = "0.2";
      hash = "sha256-UG/YZWp+twJdvqiXR4NfB3knm04lAyICh5/LHN2pm54=";
      patch = "0014-Fix-FTBFS-with-GCC-15.patch";
    })
  ];

  nativeBuildInputs = [
    autoreconfHook
    gtk-doc
    wrapGAppsHook3
    intltool
    gettext
    pkg-config
  ];

  buildInputs = [
    libjack2
    guile
    lilypond
    glib
    libxml2
    librsvg
    libsndfile
    aubio
    gtk3
    gtksourceview
    evince
    fluidsynth
    rubberband
    portaudio
    fftw
    portmidi
  ];

  # error by default in GCC 14
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH : "${lilypond}/bin"
    )
  '';

  meta = {
    description = "Music notation and composition software used with lilypond";
    homepage = "http://denemo.org";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.olynch ];
    platforms = lib.platforms.linux;
  };
})
