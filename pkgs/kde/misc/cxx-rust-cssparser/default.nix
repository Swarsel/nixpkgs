{
  lib,
  fetchFromGitLab,
  cargo,
  corrosion,
  cxx-rs,
  mkKdeDerivation,
  rustPlatform,
  rustc,
}:

mkKdeDerivation rec {
  pname = "cxx-rust-cssparser";
  version = "1.0.0";

  src = fetchFromGitLab {
    owner = "libraries";
    repo = "cxx-rust-cssparser";
    tag = "v${version}";
    hash = "sha256-zYY9GmQb/Qbbu8AhOGHfrrQ563cIrnx9KMGkdledURw=";
    domain = "invent.kde.org";
  };

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      pname
      version
      src
      cargoRoot
      ;

    hash = "sha256-CdOvP7VxS2JMD3MlRtc6QNUCGiVMGxiKayLG6vn6n+8=";
  };

  cargoRoot = "rust";
  dontWrapQtApps = true;

  extraBuildInputs = [
    corrosion
  ];

  extraNativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustc
    cargo
    cxx-rs
  ];

  meta.license = with lib.licenses; [
    bsd2
    cc0
    lgpl2Only
    lgpl3Only
  ];
}
