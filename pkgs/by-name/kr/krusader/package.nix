{
  lib,
  stdenv,
  fetchurl,
  cmake,
  kdePackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "krusader";
  version = "2.9.0";

  src = fetchurl {
    url = "mirror://kde/stable/krusader/${finalAttrs.version}/krusader-${finalAttrs.version}.tar.xz";
    hash = "sha256-ybeb+t5sxp/g40Hs75Mvysiv2f6U6MvPvXKf61Q5TgQ=";
  };

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
    kdePackages.kdoctools
    kdePackages.wrapQtAppsHook
  ];

  propagatedBuildInputs = with kdePackages; [
    karchive
    kconfig
    kcrash
    kguiaddons
    kparts
    kwindowsystem
    qt5compat
    kstatusnotifieritem
  ];

  meta = {
    description = "Norton/Total Commander clone for KDE";
    homepage = "http://www.krusader.org";
    license = lib.licenses.gpl2Only;
    mainProgram = "krusader";
  };
})
