{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  i3ipc-glib,
  libx11,
  libxcb,
  libxcb-keysyms,
  pkg-config,
  xorgproto,
}:

stdenv.mkDerivation {
  pname = "i3easyfocus";
  version = "20190411";

  src = fetchFromGitHub {
    owner = "cornerman";
    repo = "i3-easyfocus";
    rev = "fffb468f7274f9d7c9b92867c8cb9314ec6cf81a";
    hash = "sha256-1XHEAZYlzQsKn5E3eLpUVzSjPkBtuqC1sxDc+v8eYrU=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libxcb
    libxcb-keysyms
    xorgproto
    libx11.dev
    i3ipc-glib
    glib.dev
  ];

  # Makefile has no rule for 'install'
  installPhase = ''
    mkdir -p $out/bin
    cp i3-easyfocus $out/bin
  '';

  meta = {
    description = "Focus and select windows in i3";
    homepage = "https://github.com/cornerman/i3-easyfocus";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ teto ];
    platforms = lib.platforms.linux;
    mainProgram = "i3-easyfocus";
  };
}
