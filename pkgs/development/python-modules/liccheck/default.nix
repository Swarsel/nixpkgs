{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  configparser,
  pip,
  pytest-mock,
  pytestCheckHook,
  python3-openid,
  semantic-version,
  setuptools,
  toml,
}:

buildPythonPackage rec {
  pname = "liccheck";
  version = "0.9.3";

  src = fetchFromGitHub {
    owner = "dhatim";
    repo = "python-license-check";
    tag = version;
    hash = "sha256-ohq3ZsbZcyqhwmvaVF/+mo7lNde5gjbz8pwhzHi3SPY=";
  };

  nativeCheckInputs = [
    pip
    pytest-mock
    pytestCheckHook
    python3-openid
  ];

  build-system = [ setuptools ];

  dependencies = [
    configparser
    semantic-version
    toml
  ];

  pyproject = true;
  pythonImportsCheck = [ "liccheck" ];

  meta = {
    description = "Check python packages from requirement.txt and report issues";
    homepage = "https://github.com/dhatim/python-license-check";
    changelog = "https://github.com/dhatim/python-license-check/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "liccheck";
  };
}
