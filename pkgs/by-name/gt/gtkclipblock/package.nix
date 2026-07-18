{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  gtk2,
  gtk3,
  gtk4,
  meson,
  ninja,
  pkg-config,
}:

let
  distorm-src = fetchFromGitHub {
    hash = "sha256-2ftEV3TMS3HT7f96k+Pwt3Mm31fVEXcHpcbbz05jycU=";
    owner = "gdabah";
    repo = "distorm";
    rev = "3.5.2b";
  };
  pname = "gtkclipblock";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "notpeelz";
    repo = "gtkclipblock";
    rev = "v${version}";
    hash = "sha256-ok/D7M0KekN8zf8AzhcOLtedbYVRHHv3m9zEHsJfcPM=";
    fetchSubmodules = true;
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  postPatch = ''
    substituteInPlace subprojects/funchook-helper/subprojects/funchook/CMakeLists.txt \
      --replace "GIT_REPOSITORY https://github.com/gdabah/distorm.git" "SOURCE_DIR ${distorm-src}"
  '';

  nativeBuildInputs = [
    meson
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    gtk2
    gtk3
    gtk4
  ];

  dontUseCmakeConfigure = true;

  meta = {
    description = "LD_PRELOAD hack to prevent GTK programs from interacting with the primary clipboard";
    homepage = "https://github.com/notpeelz/gtkclipblock";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ uartman ];
    platforms = [ "x86_64-linux" ];
  };
}
