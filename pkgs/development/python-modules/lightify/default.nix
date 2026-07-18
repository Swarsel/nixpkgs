{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "lightify";
  version = "1.0.7.3";

  src = fetchFromGitHub {
    owner = "tfriedel";
    repo = "python-lightify";
    tag = "v${version}";
    hash = "sha256-zgDB1Tq4RYIeABZCjCcoB8NGt+ZhQFnFu655OghgpH0=";
  };

  # tests access the network
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "lightify" ];

  meta = {
    description = "Library to work with OSRAM Lightify";
    homepage = "https://github.com/tfriedel/python-lightify";
    changelog = "https://github.com/tfriedel/python-lightify/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
