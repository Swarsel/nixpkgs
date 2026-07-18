{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  gnome-common,
  gobject-introspection,
  gtk-doc,
  gtk3,
  gtk3-x11,
  libtool,
  libx11,
  libxext,
  libxrender,
  pkg-config,
  gtk3' ? (if stdenv.hostPlatform.isDarwin then gtk3-x11 else gtk3),
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "keybinder3";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "kupferlauncher";
    repo = "keybinder";
    rev = "keybinder-3.0-v${finalAttrs.version}";
    sha256 = "196ibn86j54fywfwwgyh89i9wygm4vh7ls19fn20vrnm6ijlzh9r";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoconf
    automake
    libtool
    pkg-config
    gnome-common
    gtk-doc
    gobject-introspection
  ];

  buildInputs = [
    gtk3'
    libx11
    libxext
    libxrender
  ];

  preConfigure = ''
    # NOCONFIGURE fixes 'If you meant to cross compile, use `--host'.'
    NOCONFIGURE=1 ./autogen.sh --prefix="$out"
    substituteInPlace ./configure \
      --replace "dummy pkg-config" 'dummy ''${ac_tool_prefix}pkg-config'
  '';

  meta = {
    description = "Library for registering global key bindings";
    homepage = "https://github.com/kupferlauncher/keybinder/";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
})
