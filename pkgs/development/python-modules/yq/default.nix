{
  lib,
  argcomplete,
  buildPythonPackage,
  fetchPypi,
  jq,
  pytestCheckHook,
  pyyaml,
  replaceVars,
  setuptools,
  setuptools-scm,
  tomlkit,
  xmltodict,
}:

buildPythonPackage rec {
  pname = "yq";
  version = "3.4.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ulhqGm8wz3BbL5IgZxLfIoHNMgKAIQ57e4Cty48lbjs=";
  };

  patches = [
    (replaceVars ./jq-path.patch {
      jq = "${lib.getBin jq}/bin/jq";
    })
  ];

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    argcomplete
    pyyaml
    tomlkit
    xmltodict
  ];

  enabledTestPaths = [ "test/test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "yq" ];

  meta = {
    description = "Command-line YAML/XML/TOML processor - jq wrapper for YAML, XML, TOML documents";
    homepage = "https://github.com/kislyuk/yq";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      SuperSandro2000
    ];

    mainProgram = "yq";
  };
}
