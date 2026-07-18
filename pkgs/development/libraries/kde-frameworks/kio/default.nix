{
  lib,
  stdenv,
  acl,
  attr,
  cmake,
  extra-cmake-modules,
  karchive,
  kbookmarks,
  kcompletion,
  kconfig,
  kconfigwidgets,
  kcoreaddons,
  kcrash,
  kdbusaddons,
  kded,
  kdoctools,
  ki18n,
  kiconthemes,
  kitemviews,
  kjobwidgets,
  knotifications,
  kservice,
  ktextwidgets,
  kwallet,
  kwidgetsaddons,
  kwindowsystem,
  kxmlgui,
  libkrb5,
  mkDerivation,
  qtbase,
  qtscript,
  qttools,
  qtx11extras,
  solid,
  util-linux,
}:

mkDerivation {
  pname = "kio";

  outputs = [
    "out"
    "dev"
  ];

  patches = [
    ./0001-Remove-impure-smbd-search-path.patch
  ];

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
    kdoctools
  ];

  buildInputs = [
    karchive
    kconfigwidgets
    kdbusaddons
    ki18n
    kiconthemes
    knotifications
    ktextwidgets
    kwallet
    kwidgetsaddons
    kwindowsystem
    qtscript
    qtx11extras
    kcrash
    libkrb5
  ]
  ++ lib.lists.optionals stdenv.hostPlatform.isLinux [
    acl
    attr # both are needed for ACL support
    util-linux # provides libmount
  ];

  propagatedBuildInputs = [
    kbookmarks
    kcompletion
    kconfig
    kcoreaddons
    kitemviews
    kjobwidgets
    kservice
    kxmlgui
    qtbase
    qttools
    solid
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    kded
  ];

  separateDebugInfo = true;

  meta = {
    homepage = "https://api.kde.org/frameworks/kio/html/";
  };
}
