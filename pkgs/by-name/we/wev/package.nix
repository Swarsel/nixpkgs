{
  lib,
  stdenv,
  fetchFromSourcehut,
  libxkbcommon,
  pkg-config,
  scdoc,
  wayland,
  wayland-protocols,
  wayland-scanner,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "wev";
  version = "1.1.0";

  src = fetchFromSourcehut {
    owner = "~sircmpwn";
    repo = "wev";
    rev = finalAttrs.version;
    hash = "sha256-0ZA44dMDuVYfplfutOfI2EdPNakE9KnOuRfk+CEDCRk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    scdoc
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    libxkbcommon
  ];

  # for scdoc
  depsBuildBuild = [
    pkg-config
  ];

  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Wayland event viewer";

    longDescription = ''
      This is a tool for debugging events on a Wayland window, analogous to the
      X11 tool xev.
    '';

    homepage = "https://git.sr.ht/~sircmpwn/wev";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ wineee ];
    platforms = lib.platforms.linux;
    mainProgram = "wev";
  };
})
