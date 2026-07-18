{
  cmake,
  extra-cmake-modules,
  kauth,
  kcodecs,
  kconfig,
  kdoctools,
  kguiaddons,
  ki18n,
  kwidgetsaddons,
  mkDerivation,
  qtbase,
  qttools,
}:

mkDerivation {
  pname = "kconfigwidgets";

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    kdoctools
  ];

  buildInputs = [
    kguiaddons
    ki18n
    qtbase
    qttools
  ];

  propagatedBuildInputs = [
    kauth
    kcodecs
    kconfig
    kwidgetsaddons
  ];

  postInstall = ''
    moveToOutput ''${qtPluginPrefix:?}/designer/kconfigwidgets5widgets.so "$out"
  '';

  outputBin = "dev";
}
