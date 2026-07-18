{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pytestCheckHook,
  pythonAtLeast,
  pyyaml,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "configargparse";
  version = "1.7.5";

  src = fetchFromGitHub {
    owner = "bw2";
    repo = "ConfigArgParse";
    tag = "v${version}";
    hash = "sha256-ZRdwA3X1TCv0BIwr1gFeSi6UuziXiazciKw/6ewkpRE=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    mock
  ]
  ++ lib.concatAttrValues optional-dependencies;

  build-system = [
    setuptools-scm
  ];

  disabledTests = lib.optionals (pythonAtLeast "3.13") [
    # regex mismatch
    "testMutuallyExclusiveArgs"
  ];

  format = "setuptools";

  optional-dependencies = {
    yaml = [ pyyaml ];
  };

  pythonImportsCheck = [ "configargparse" ];

  meta = {
    description = "Drop-in replacement for argparse";
    homepage = "https://github.com/bw2/ConfigArgParse";
    changelog = "https://github.com/bw2/ConfigArgParse/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
