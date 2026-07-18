{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  autoreconfHook,
  gettext,
  gtk3,
  intltool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "volumeicon";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "Maato";
    repo = "volumeicon";
    rev = finalAttrs.version;
    hash = "sha256-zYKC7rOoLf08rV4B43TrGNBcXfSBFxWZCe9bQD9JzaA";
  };

  nativeBuildInputs = [
    autoreconfHook
    intltool
    pkg-config
  ];

  buildInputs = [
    gtk3
    alsa-lib
  ];

  # Work around regressions introduced by bad interaction between
  # gettext >= 0.25 and autoconf (2.72 at the time of writing).
  env.ACLOCAL = "aclocal -I ${gettext}/share/gettext/m4";

  meta = {
    description = "Lightweight volume control that sits in your systray";
    homepage = "https://nullwise.com/pages/volumeicon/volumeicon.html";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ bobvanderlinden ];
    platforms = lib.platforms.linux;
    mainProgram = "volumeicon";
  };
})
