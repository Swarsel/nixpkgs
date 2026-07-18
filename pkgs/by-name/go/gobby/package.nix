{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gsasl,
  gtkmm3,
  gtksourceview3,
  intltool,
  itstool,
  libinfinity,
  libxmlxx,
  pkg-config,
  wrapGAppsHook3,
  yelp-tools,
  avahiSupport ? false, # build support for Avahi in libinfinity
}:

let
  libinf = libinfinity.override {
    inherit avahiSupport;
    gtkWidgets = true;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "gobby";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "gobby";
    repo = "gobby";
    rev = "v${finalAttrs.version}";
    sha256 = "06cbc2y4xkw89jaa0ayhgh7fxr5p2nv3jjs8h2xcbbbgwaw08lk0";
  };

  nativeBuildInputs = [
    autoconf
    automake
    pkg-config
    intltool
    itstool
    yelp-tools
    wrapGAppsHook3
  ];

  buildInputs = [
    gtkmm3
    gsasl
    gtksourceview3
    libxmlxx
    libinf
  ];

  preConfigure = "./autogen.sh";

  meta = {
    description = "GTK-based collaborative editor supporting multiple documents in one session and a multi-user chat";
    homepage = "http://gobby.0x539.de/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "gobby-0.5";
  };
})
