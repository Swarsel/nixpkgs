{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  gtk2,
  libxcb,
  libxcb-util,
  pkg-config,
  spice,
  spice-protocol,
  util-macros,
}:

stdenv.mkDerivation {
  pname = "x11spice";
  version = "2019-08-20";

  src = fetchFromGitLab {
    owner = "spice";
    repo = "x11spice";
    rev = "51d2a8ba3813469264959bb3ba2fc6fe08097be6";
    sha256 = "0va5ix14vnqch59gq8wvrhw6q0w0n27sy70xx5kvfj2cl0h1xpg8";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libxcb
    libxcb-util
    util-macros
    gtk2
    spice
    spice-protocol
  ];

  env.NIX_LDFLAGS = "-lpthread";

  meta = {
    description = "Enable a running X11 desktop to be available via a Spice server";
    homepage = "https://gitlab.freedesktop.org/spice/x11spice";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ rnhmjoj ];
    platforms = lib.platforms.linux;
  };
}
