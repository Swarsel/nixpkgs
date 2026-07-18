{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  packaging,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "dparse";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "pyupio";
    repo = "dparse";
    tag = version;
    hash = "sha256-LnsmJtWLjV3xoSjacfR9sUwPlOjQTRBWirJVtIJSE8A=";
  };

  nativeCheckInputs = [
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [ hatchling ];
  dependencies = [ packaging ];

  disabledTests = [
    # requires unpackaged dependency pipenv
    "test_update_pipfile"
  ];

  optional-dependencies = {
    # FIXME pipenv = [ pipenv ];
    conda = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "dparse" ];

  meta = {
    description = "Parser for Python dependency files";
    homepage = "https://github.com/pyupio/dparse";
    changelog = "https://github.com/pyupio/dparse/blob/${version}/HISTORY.rst";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thomasdesr ];
  };
}
