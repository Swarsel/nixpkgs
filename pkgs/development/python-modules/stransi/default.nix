{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  ochre,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "stransi";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "getcuia";
    repo = "stransi";
    rev = "v${version}";
    hash = "sha256-PDMel6emra5bzX+FwHvUVpFu2YkRKy31UwkCL4sGJ14=";
  };

  nativeBuildInputs = [ poetry-core ];
  propagatedBuildInputs = [ ochre ];

  nativeCheckInputs = [
    hypothesis
    pytestCheckHook
  ];

  pyproject = true;
  pythonImportsCheck = [ "stransi" ];

  meta = {
    description = "Lightweight Python parser library for ANSI escape code sequences";
    homepage = "https://github.com/getcuia/stransi";
    changelog = "https://github.com/getcuia/stransi/releases/tag/${src.rev}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
