{
  lib,
  stdenv,
  libsForQt5,
  makeWrapper,
  nixosTests,
  symlinkJoin,
  extraPythonPackages ? (ps: [ ]),
  # unwrapped package parameters
  withGrass ? false,
  withServer ? false,
}:
let
  qgis-ltr-unwrapped = libsForQt5.callPackage ./unwrapped-ltr.nix {
    inherit withGrass withServer;
  };
in

symlinkJoin {
  inherit (qgis-ltr-unwrapped) version outputs src;
  inherit (qgis-ltr-unwrapped) meta;
  pname = "qgis-ltr";

  nativeBuildInputs = [
    makeWrapper
    qgis-ltr-unwrapped.py.pkgs.wrapPython
  ];

  postBuild = ''
    buildPythonPath "$pythonInputs"

    for program in $out/bin/*; do
      wrapProgram $program \
        --prefix PATH : $program_PATH \
        --set PYTHONPATH $program_PYTHONPATH
    done
  ''
  + lib.optionalString (!stdenv.hostPlatform.isDarwin) ''
    ln -s ${qgis-ltr-unwrapped.man} $man
  '';

  paths = [ qgis-ltr-unwrapped ];

  # extend to add to the python environment of QGIS without rebuilding QGIS application.
  pythonInputs =
    qgis-ltr-unwrapped.pythonBuildInputs ++ (extraPythonPackages qgis-ltr-unwrapped.py.pkgs);

  passthru = {
    tests.qgis-ltr = nixosTests.qgis-ltr;
    unwrapped = qgis-ltr-unwrapped;

    updateScript = [
      ./update.sh
      "qgis-ltr"
    ];
  };
}
