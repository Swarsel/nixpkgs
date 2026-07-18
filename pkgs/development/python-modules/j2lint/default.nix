{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  pytest-cov-stub,
  pytestCheckHook,
  rich,
  setuptools,
  versionCheckHook,
}:

buildPythonPackage rec {
  pname = "j2lint";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "aristanetworks";
    repo = "j2lint";
    rev = "v${version}";
    hash = "sha256-/3hd2RnyxX4CsqWvsmGB/5QoeQIsFhtG3nntHer0or8=";
  };

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
    versionCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    jinja2
    rich
  ];

  pyproject = true;

  meta = {
    description = "Jinja2 Linter CLI";
    homepage = "https://github.com/aristanetworks/j2lint";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ polyfloyd ];
  };
}
