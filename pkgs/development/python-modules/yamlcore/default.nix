{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyyaml,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "yamlcore";
  version = "0.0.4";

  src = fetchFromGitHub {
    owner = "perlpunk";
    repo = "pyyaml-core";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TBVNmuhBfEo9HmDkalnn6VDVHF+sh/MIZ8f46Zdyxw8=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
  ];

  dependencies = [
    pyyaml
  ];

  enabledTestPaths = [ "tests/*.py" ];
  pyproject = true;
  pythonImportsCheck = [ "yamlcore" ];

  meta = {
    description = "YAML 1.2 Support for PyYAML";
    homepage = "https://github.com/perlpunk/pyyaml-core";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gonsolo ];
  };
})
