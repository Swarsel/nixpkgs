{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "neurio";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "jordanh";
    repo = "neurio-python";
    tag = version;
    hash = "sha256-Kyjx+76OR3fpA9p/Zg7S4/vuGuNU2kb022BijoNMSUI=";
  };

  # Project has tests but they require actual API credentials
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "neurio" ];

  meta = {
    description = "Neurio energy sensor and appliance automation API library";
    homepage = "https://github.com/jordanh/neurio-python";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.jamiemagee ];
  };
}
