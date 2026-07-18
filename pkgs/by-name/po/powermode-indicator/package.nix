{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glibmm,
  gtkmm3,
  libappindicator,
  pkg-config,
}:
stdenv.mkDerivation {
  pname = "powermode-indicator";
  version = "0-unstable-2024-07-13";

  src = fetchFromGitHub {
    owner = "PiyushXCoder";
    repo = "powermode-indicator";
    rev = "0a67f63290b087f1eeff2c6c6869c2122ac78e6f";
    hash = "sha256-qqV99s+uNYCUx/xGY3gQL38eG9siuKTRT0bA2UoN6Sk=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libappindicator
    gtkmm3
    glibmm
  ];

  meta = {
    description = "Tray tool for power profiles management";
    homepage = "https://github.com/PiyushXCoder/powermode-indicator";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.aacebedo ];
    platforms = lib.platforms.linux;
    mainProgram = "powermode-indicator";
  };
}
