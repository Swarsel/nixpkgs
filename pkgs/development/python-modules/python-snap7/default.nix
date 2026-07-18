{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  snap7,
}:

buildPythonPackage rec {
  pname = "python-snap7";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "gijzelaerr";
    repo = "python-snap7";
    tag = version;
    hash = "sha256-l7nLW7qrIloa6JlQTubXnISljsC7jkdAjye9AAUTDrw=";
  };

  # Tests require root privileges to open privileged ports
  doCheck = false;
  build-system = [ setuptools ];

  prePatch = ''
    substituteInPlace snap7/common.py \
      --replace "lib_location = None" "lib_location = '${snap7}/lib/libsnap7.so'"
  '';

  pyproject = true;

  pythonImportsCheck = [
    "snap7"
    "snap7.util"
  ];

  meta = {
    description = "Python wrapper for the snap7 PLC communication library";
    homepage = "https://github.com/gijzelaerr/python-snap7";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "snap7-server";
  };
}
