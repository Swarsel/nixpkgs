{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  pillow,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "blurhash";
  version = "1.1.5";

  src = fetchFromGitHub {
    owner = "halcy";
    repo = "blurhash-python";
    tag = "v${version}";
    hash = "sha256-lTPn2GTD7eQ9XkZyuttFqEvNgzcx6b7OdeMc5WOXrJs=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    pillow
    numpy
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "blurhash" ];

  meta = {
    description = "Pure-Python implementation of the blurhash algorithm";
    homepage = "https://github.com/halcy/blurhash-python";
    changelog = "https://github.com/halcy/blurhash-python/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
