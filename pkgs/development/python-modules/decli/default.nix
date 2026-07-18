{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "decli";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "woile";
    repo = "decli";
    tag = "v${version}";
    hash = "sha256-W4GURqlkHzDwrPAlmiBjc2ZqN//nUK084uRMM7GIme0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  pyproject = true;
  pythonImportsCheck = [ "decli" ];

  meta = {
    description = "Minimal, easy to use, declarative command line interface tool";
    homepage = "https://github.com/Woile/decli";
    changelog = "https://github.com/woile/decli/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ lovesegfault ];
  };
}
