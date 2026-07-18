{
  lib,
  stdenv,
  fetchurl,
  glib,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvterm";
  version = "0.99.7";

  src = fetchurl {
    url = "mirror://sourceforge/libvterm/libvterm-${finalAttrs.version}.tar.gz";
    sha256 = "10gaqygmmwp0cwk3j8qflri5caf8vl3f7pwfl2svw5whv8wkn0k2";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace "gcc" "${stdenv.cc.targetPrefix}cc" \
      --replace "ldconfig" "" \
      --replace "/usr" "$out"

    makeFlagsArray+=("PKG_CFG=`${stdenv.cc.targetPrefix}pkg-config --cflags glib-2.0`")
  '';

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ ncurses ];
  # For headers
  propagatedBuildInputs = [ glib ];

  preInstall = ''
    mkdir -p $out/include $out/lib
  '';

  meta = {
    description = "Terminal emulator library to mimic both vt100 and rxvt";
    homepage = "http://libvterm.sourceforge.net/";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.linux;
  };
})
