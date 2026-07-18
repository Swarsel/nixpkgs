{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "flask-themer";
  version = "2.0.0";

  # Pypi tarball doesn't contain tests/
  src = fetchFromGitHub {
    owner = "TkTech";
    repo = "flask-themer";
    tag = "v${version}";
    hash = "sha256-2Zw+gKKN0kfjYuruuLQ+3dIFF0X07DTy0Ypc22Ih66w=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  build-system = [ setuptools ];
  dependencies = [ flask ];
  pyproject = true;
  pythonImportsCheck = [ "flask_themer" ];

  meta = {
    description = "Simple theming support for Flask apps";
    homepage = "https://github.com/TkTech/flask-themer";
    changelog = "https://github.com/TkTech/flask-themer/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ erictapen ];
  };
}
