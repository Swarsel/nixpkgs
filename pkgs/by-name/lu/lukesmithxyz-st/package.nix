{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  harfbuzz,
  libx11,
  libxext,
  libxft,
  ncurses,
  pkg-config,
}:

stdenv.mkDerivation {
  pname = "lukesmithxyz-st";
  version = "0.pre+unstable=2021-08-10";

  src = fetchFromGitHub {
    owner = "LukeSmithxyz";
    repo = "st";
    rev = "e053bd6036331cc7d14f155614aebc20f5371d3a";
    hash = "sha256-WwjuNxWoeR/ppJxJgqD20kzrn1kIfgDarkTOedX/W4k=";
  };

  patches = [
    # eliminate useless calls to git inside Makefile
    ./0000-makefile-fix-install.diff
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    fontconfig
    harfbuzz
    libx11
    libxext
    libxft
    ncurses
  ];

  installPhase = ''
    runHook preInstall

    TERMINFO=$out/share/terminfo make install PREFIX=$out

    runHook postInstall
  '';

  meta = {
    description = "Luke Smith's fork of st";
    homepage = "https://github.com/LukeSmithxyz/st";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
