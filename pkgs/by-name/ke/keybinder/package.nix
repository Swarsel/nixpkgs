{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gnome-common,
  gobject-introspection,
  gtk-doc,
  gtk2,
  libtool,
  lua5_1,
  pkg-config,
}:
let
  lua = lua5_1;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "keybinder";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "kupferlauncher";
    repo = "keybinder";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-elL6DZtzCwAtoyGZYP0jAma6tHPks2KAtrziWtBENGU=";
  };

  nativeBuildInputs = [
    pkg-config
    autoconf
    automake
    gobject-introspection
  ];

  buildInputs = [
    libtool
    gnome-common
    gtk-doc
    gtk2
    lua
  ];

  configureFlags = [ "--disable-python" ];

  preConfigure = ''
    ./autogen.sh --prefix="$out" $configureFlags
  '';

  meta = {
    description = "Library for registering global key bindings";

    longDescription = ''
      keybinder is a library for registering global keyboard shortcuts.
      Keybinder works with GTK-based applications using the X Window System.

      The library contains:

      * A C library, ``libkeybinder``
      * Gobject-Introspection (gir)  generated bindings
      * Lua bindings, ``lua-keybinder``
    '';

    homepage = "https://github.com/kupferlauncher/keybinder/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.linux;
  };
})
