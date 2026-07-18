{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  gcc,
  gnumake,
  jack1,
  libevdev,
  lua5_4,
  ncurses,
  openssl,
  pkg-config,
  python3,
}:

stdenv.mkDerivation {
  pname = "midimonster";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "cbdevnet";
    repo = "midimonster";
    rev = "f16f7db86662fcdbf45b6373257c90c824b0b4b0";
    sha256 = "131zs4j9asq9xl72cbyi463xpkj064ca1s7i77q5jrwqysgy52sp";
  };

  outputs = [
    "out"
    "man"
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    gnumake
    gcc
    lua5_4
    openssl
    jack1
    python3
    alsa-lib
    ncurses
    libevdev
  ];

  buildPhase = ''
    PLUGINS=$out/lib/midimonster make all
  '';

  doCheck = true;

  installPhase = ''
    PREFIX=$out make install

    mkdir -p "$man/share/man/man1"
    cp assets/midimonster.1 "$man/share/man/man1"

    mkdir -p "$out/share/icons/hicolor/scalable/apps"
    cp assets/MIDIMonster.svg "$out/share/icons/hicolor/scalable/apps/"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Multi-protocol translation tool";
    homepage = "https://midimonster.net";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ keldu ];
    platforms = lib.platforms.unix;
    mainProgram = "midimonster";
  };
}
