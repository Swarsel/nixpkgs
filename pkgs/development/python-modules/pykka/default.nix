{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pydantic,
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pykka";
  version = "4.4.2";

  src = fetchFromGitHub {
    owner = "jodal";
    repo = "pykka";
    tag = "v${version}";
    hash = "sha256-ij5djc+6CjIC9HLxOJorMFdNRnxOoS37+oAmI8Lo5pc=";
  };

  nativeCheckInputs = [
    pydantic
    pytestCheckHook
    pytest-mock
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "pykka" ];

  meta = {
    description = "Python implementation of the actor model";
    homepage = "https://www.pykka.org/";
    changelog = "https://github.com/jodal/pykka/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
