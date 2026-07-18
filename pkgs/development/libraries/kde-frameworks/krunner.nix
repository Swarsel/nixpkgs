{
  cmake,
  extra-cmake-modules,
  kconfig,
  kcoreaddons,
  ki18n,
  kio,
  kservice,
  kwindowsystem,
  mkDerivation,
  plasma-framework,
  qtbase,
  qtdeclarative,
  solid,
  threadweaver,
}:

let
  self = mkDerivation {
    pname = "krunner";

    nativeBuildInputs = [
      cmake
      extra-cmake-modules
    ];

    buildInputs = [
      kconfig
      kcoreaddons
      ki18n
      kio
      kservice
      qtdeclarative
      solid
      threadweaver
    ];

    propagatedBuildInputs = [
      plasma-framework
      qtbase
      kwindowsystem
    ];
  };
in
self
