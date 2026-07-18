{
  lib,
  stdenv,
  fetchurl,
  cmake,
  libgig,
  liblscp,
  pkg-config,
  qt6,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qsampler";
  version = "1.0.1";

  src = fetchurl {
    url = "mirror://sourceforge/qsampler/qsampler-${finalAttrs.version}.tar.gz";
    hash = "sha256-cvdnVE3FmsgLy5s6N2nX+2fM4Nyri+rUaxQQeWGluxo=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    liblscp
    qt6.qtbase
  ];

  qtWrapperArgs = [ "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libgig ]}" ];

  meta = {
    description = "LinuxSampler GUI front-end application";
    homepage = "https://qsampler.sourceforge.io";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "qsampler";
  };
})
