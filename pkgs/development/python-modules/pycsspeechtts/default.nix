{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  requests,
}:

buildPythonPackage rec {
  pname = "pycsspeechtts";
  version = "1.0.8";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-kgof0T22VRU96pKAWuEBo56F6t7o2X/xRS/L5B7UYDY=";
  };

  # Tests require API key and network access
  doCheck = false;
  build-system = [ hatchling ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "pycsspeechtts" ];

  meta = {
    description = "Python library for Microsoft Cognitive Services Text-to-Speech";
    homepage = "https://github.com/jeroenterheerdt/pycsspeechtts";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
