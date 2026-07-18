{
  lib,
  stdenv,
  fetchFromGitLab,
  libevdev,
  pkg-config,
  yaml-cpp,
}:

stdenv.mkDerivation rec {
  pname = "dual-function-keys";
  version = "1.5.0";

  src = fetchFromGitLab {
    owner = "linux/plugins";
    repo = pname;
    rev = version;
    hash = "sha256-m/oEczUNKqj0gs/zMOIBxoQaffNg+YyPINMXArkATJ4=";
    group = "interception";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libevdev
    yaml-cpp
  ];

  installFlags = [
    "DESTDIR=$(out)"
    "PREFIX="
  ];

  prePatch = ''
    substituteInPlace config.mk --replace \
      '/usr/include/libevdev-1.0' \
      "$(pkg-config --cflags libevdev | cut -c 3-)"
  '';

  meta = {
    description = "Tap for one key, hold for another";
    homepage = "https://gitlab.com/interception/linux/plugins/dual-function-keys";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ svend ];
    platforms = lib.platforms.linux;
    mainProgram = "dual-function-keys";
  };
}
