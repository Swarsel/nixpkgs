{
  lib,
  stdenv,
  fetchurl,
  cmake,
  docbook-xsl-nons,
  pkg-config,
  qt6,
  qt6Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "vmpk";
  version = "0.9.2";

  src = fetchurl {
    url = "mirror://sourceforge/vmpk/${finalAttrs.version}/vmpk-${finalAttrs.version}.tar.bz2";
    hash = "sha256-FUVI6Ioe4zmQa84pqGlw/my2Rw8fpMcZi9bZu/gzIGA=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qttools
    docbook-xsl-nons
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6Packages.drumstick
  ];

  postInstall = ''
    # vmpk drumstickLocales looks here:
    ln -s ${qt6Packages.drumstick}/share/drumstick $out/share/
  '';

  meta = {
    description = "Virtual MIDI Piano Keyboard";
    homepage = "http://vmpk.sourceforge.net/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "vmpk";
  };
})
