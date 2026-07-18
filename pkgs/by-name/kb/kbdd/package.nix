{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  dbus-glib,
  libx11,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "kbdd";
  version = "unstable-2025-08-10";

  src = fetchFromGitHub {
    owner = "qnikst";
    repo = "kbdd";
    rev = "b87e44afd5859157245eee22b11827605bfa09b9";
    hash = "sha256-cbMcB6jgssfMUjemBOiE06zJK2TbzOWt1Rvt41V33Mo=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libx11
    dbus-glib
  ];

  meta = {
    description = "Simple daemon and library to make per window layout using XKB";
    homepage = "https://github.com/qnikst/kbdd";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "kbdd";
  };
}
