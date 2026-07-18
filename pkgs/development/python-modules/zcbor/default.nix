{
  lib,
  buildPythonPackage,
  # dependencies
  cbor2,
  fetchPypi,
  pyyaml,
  regex,
  # build dependencies
  setuptools,
}:

buildPythonPackage rec {
  pname = "zcbor";
  version = "0.9.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-wEkYOS4tuxTG8DjXduLqawnDS6ECiwRardfDqVYWvDg=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    cbor2
    pyyaml
    regex
  ];

  pyproject = true;
  pythonImportsCheck = [ "zcbor" ];

  meta = {
    description = "Low footprint CBOR library in the C language (C++ compatible), tailored for use in microcontrollers";
    homepage = "https://pypi.org/project/zcbor/";
    changelog = "https://github.com/NordicSemiconductor/zcbor/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ otavio ];
    mainProgram = "zcbor";
  };
}
