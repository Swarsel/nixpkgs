{
  lib,
  fetchFromGitHub,
  python312Packages,
}:
let
  version = "0.1.3";
in
python312Packages.buildPythonApplication rec {
  inherit version;
  pname = "sl1-to-photon";

  src = fetchFromGitHub {
    owner = "cab404";
    repo = "SL1toPhoton";
    rev = "7edc6ea99818622f5d49ac7af80ddd4916b8c19f";
    sha256 = "sha256-ssFfjlBMi3FHosDBUA2gs71VUIBkEdPVcV3STNxmOIM=";
  };

  installPhase = ''
    install -D -m 0755 SL1_to_Photon.py $out/bin/${pname}
  '';

  format = "setuptools";

  pythonPath = with python312Packages; [
    pyphotonfile
    pillow
    numpy
    pyside2
    shiboken2
  ];

  meta = {
    description = "Tool for converting Slic3r PE's SL1 files to Photon files for the Anycubic Photon 3D-Printer";
    homepage = "https://github.com/cab404/SL1toPhoton";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.cab404 ];
    mainProgram = "sl1-to-photon";
  };

}
