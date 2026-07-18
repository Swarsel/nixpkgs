{
  lib,
  buildPythonPackage,
  fetchPypi,
  setuptools,
  zeep,
}:

buildPythonPackage rec {
  pname = "onvif-zeep";
  version = "0.2.12";

  src = fetchPypi {
    inherit version;
    hash = "sha256-qou8Aqc+qlCJSwwY45+o0xilg6ZkxlvzWzyAKdHEC0k=";
    pname = "onvif_zeep";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ zeep ];
  # Tests require hardware
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "onvif" ];

  meta = {
    description = "Python Client for ONVIF Camera";
    homepage = "https://github.com/quatanium/python-onvif";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fleaz ];
    mainProgram = "onvif-cli";
  };
}
