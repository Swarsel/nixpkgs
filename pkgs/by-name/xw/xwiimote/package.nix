{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  ncurses,
  pkg-config,
  udev,
}:

stdenv.mkDerivation {
  pname = "xwiimote";
  version = "2-unstable-2024-02-29";

  src = fetchFromGitHub {
    owner = "xwiimote";
    repo = "xwiimote";
    rev = "4df713d9037d814cc0c64197f69e5c78d55caaf1";
    hash = "sha256-y68bi62H7ErVekcs0RZUXPpW+QJ97sTQP4lajB9PsgU=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    udev
    ncurses
  ];

  configureFlags = [ "--with-doxygen=no" ];

  postInstallPhase = ''
    mkdir -p "$out/etc/X11/xorg.conf.d/"
    cp "res/50-xorg-fix-xwiimote.conf" "$out/etc/X11/xorg.conf.d/50-fix-xwiimote.conf"
  '';

  meta = {
    description = "Userspace utilities to control connected Nintendo Wii Remotes";
    homepage = "https://xwiimote.github.io/xwiimote/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pyrox0 ];
    platforms = lib.platforms.linux;
    mainProgram = "xwiishow";
  };
}
