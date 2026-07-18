{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  libxml2,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "evtest";
  version = "1.36";

  src = fetchFromGitLab {
    owner = "libevdev";
    repo = "evtest";
    tag = "evtest-${finalAttrs.version}";
    sha256 = "sha256-M7AGcHklErfRIOu64+OU397OFuqkAn4dqZxx7sDfklc=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [ libxml2 ];

  meta = {
    description = "Simple tool for input event debugging";
    homepage = "https://gitlab.freedesktop.org/libevdev/evtest";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = lib.platforms.linux;
    mainProgram = "evtest";
  };
})
