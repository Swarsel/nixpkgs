{
  lib,
  stdenv,
  lazarus,
  qmake,
  qtbase,
  # Not in Qt6 anymore
  qtx11extras ? null,
}:

let
  qtVersion = lib.versions.major qtbase.version;
in
stdenv.mkDerivation {
  inherit (lazarus) version src;
  pname = "libqtpas";

  postPatch = ''
    substituteInPlace Qt${qtVersion}Pas.pro \
      --replace 'target.path = $$[QT_INSTALL_LIBS]' "target.path = $out/lib"
  '';

  nativeBuildInputs = [ qmake ];

  buildInputs = [
    qtbase
  ]
  ++ lib.optionals (qtVersion == "5") [
    qtx11extras
  ];

  dontWrapQtApps = true;
  sourceRoot = "lazarus/lcl/interfaces/qt${qtVersion}/cbindings";

  meta = {
    inherit (lazarus.meta) license platforms;
    description = "Free Pascal Qt${qtVersion} binding library";

    homepage =
      "https://wiki.freepascal.org/Qt${qtVersion}_Interface"
      + lib.optionalString (qtVersion == "5") "#libqt5pas";

    maintainers = with lib.maintainers; [ sikmir ];
  };
}
