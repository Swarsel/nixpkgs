{
  lib,
  stdenv,
  fetchFromGitHub,
  boost186,
  qt5,
}:

let
  inherit (qt5) qmake wrapQtAppsHook;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "zegrapher";
  version = "3.1.1";

  src = fetchFromGitHub {
    owner = "AdelKS";
    repo = "ZeGrapher";
    rev = "v${finalAttrs.version}";
    hash = "sha256-OSQXm0gDI1zM2MBM4iiY43dthJcAZJkprklolsNMEvk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    qmake
    wrapQtAppsHook
  ];

  buildInputs = [
    boost186
  ];

  meta = {
    description = "Open source math plotter";

    longDescription = ''
      An open source, free and easy to use math plotter. It can plot functions,
      sequences, parametric equations and data on the plane.
    '';

    homepage = "https://zegrapher.com/en/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "ZeGrapher";
  };
})
