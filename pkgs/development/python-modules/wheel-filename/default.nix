{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "wheel-filename";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "jwodder";
    repo = "wheel-filename";
    tag = "v${version}";
    hash = "sha256-YlJ3mQoaNY7wiLzADLZuTET5i37e/zn2S7n9dOdcE0E=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "wheel_filename" ];

  meta = {
    description = "Parse wheel filenames";
    homepage = "https://github.com/jwodder/wheel-filename";
    changelog = "https://github.com/wheelodex/wheel-filename/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ayazhafiz ];
    mainProgram = "wheel-filename";
  };
}
