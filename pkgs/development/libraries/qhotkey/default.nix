{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  qtbase,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qhotkey";
  version = "1.5.0-unstable-2025-07-06";

  src = fetchFromGitHub {
    owner = "Skycoder42";
    repo = "qhotkey";
    rev = "6c0e98492c59206139f8490706aadeb8ed033057";
    hash = "sha256-F+NTVYIB55GlB+p9mgDvJD86n0xOOKMGCRDM8TtnMpo=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    qtbase
  ];

  cmakeFlags = [
    "-DQT_DEFAULT_MAJOR_VERSION=${lib.versions.major qtbase.version}"
  ];

  dontWrapQtApps = true;

  meta = {
    description = "Global shortcut/hotkey for Desktop Qt-Applications";
    homepage = "https://github.com/Skycoder42/QHotkey";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dmkhitaryan ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
