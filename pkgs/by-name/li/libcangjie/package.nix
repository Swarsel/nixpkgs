{
  lib,
  stdenv,
  fetchFromGitLab,
  cppcheck,
  meson,
  ninja,
  pkg-config,
  sqlite,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libcangjie";
  version = "1.4.0";

  src = fetchFromGitLab {
    owner = "cangjie";
    repo = "libcangjie";
    rev = "v${finalAttrs.version}";
    hash = "sha256-LZRU2hbAC8xftPAIHDKCa2SfFLuH/PVqvjZmOSoUQwc=";
    domain = "gitlab.freedesktop.org";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    sqlite
    cppcheck
  ];

  doCheck = true;

  meta = {
    description = "C library implementing the Cangjie input method";
    homepage = "https://gitlab.freedesktop.org/cangjie/libcangjie";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "libcangjie-cli";
  };
})
