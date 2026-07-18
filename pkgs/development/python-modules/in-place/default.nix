{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "in-place";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "jwodder";
    repo = "inplace";
    tag = "v${version}";
    hash = "sha256-PyOSuHHtftEPwL3mTwWYStZNXYX3EhptKfTu0PJjOZ8=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ hatchling ];
  pyproject = true;
  pythonImportsCheck = [ "in_place" ];

  meta = {
    description = "In-place file processing";
    homepage = "https://github.com/jwodder/inplace";
    changelog = "https://github.com/jwodder/inplace/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ samuela ];
  };
}
