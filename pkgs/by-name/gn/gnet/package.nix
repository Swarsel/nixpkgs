{
  lib,
  stdenv,
  fetchFromGitLab,
  autoconf,
  automake,
  glib,
  libtool,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gnet";
  version = "2.0.8";

  src = fetchFromGitLab {
    owner = "Archive";
    repo = "gnet";
    rev = "GNET_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-B2H8s1JWNrvVR8qn6UFfAaCXQd0zEpNaLUPET99Ex7M=";
    domain = "gitlab.gnome.org";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
  ];

  buildInputs = [
    glib
    libtool
  ];

  preConfigure = "./autogen.sh";

  meta = {
    description = "Network library, written in C, object-oriented, and built upon GLib";
    homepage = "https://gitlab.gnome.org/Archive/gnet";
    license = lib.licenses.lgpl2;
    maintainers = with lib.maintainers; [ pSub ];
    platforms = lib.platforms.linux;
  };
})
