{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry,
  poetry-core,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "poetry-plugin-export";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "python-poetry";
    repo = "poetry-plugin-export";
    tag = version;
    hash = "sha256-KsvkM4hjG+jrdPVauXYdc6E87Gp7srMg/mJHpWRjaEs=";
  };

  buildInputs = [
    poetry
  ];

  nativeCheckInputs = [
    pytest-mock
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    poetry-core
  ];

  pyproject = true;

  meta = {
    description = "Poetry plugin to export the dependencies to various formats";
    homepage = "https://github.com/python-poetry/poetry-plugin-export";
    changelog = "https://github.com/python-poetry/poetry-plugin-export/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
