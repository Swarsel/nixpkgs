{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  msgpack,
  pytestCheckHook,
  pyyaml,
  ruamel-yaml,
  setuptools,
  toml,
  tomli-w,
}:

buildPythonPackage rec {
  pname = "python-box";
  version = "7.3.2";

  src = fetchFromGitHub {
    owner = "cdgriffith";
    repo = "Box";
    tag = version;
    hash = "sha256-aVPjIoizqC0OcG5ziy/lvp/JsFSUvcLUqJ03mKViKFs=";
  };

  nativeCheckInputs = [ pytestCheckHook ] ++ optional-dependencies.all;

  build-system = [
    cython
    setuptools
  ];

  disabledTests = [
    # ruamel 8.18.13 update changed white space rules
    "test_to_yaml_ruamel"
  ];

  optional-dependencies = {
    PyYAML = [ pyyaml ];

    all = [
      msgpack
      ruamel-yaml
      toml
    ];

    msgpack = [ msgpack ];
    ruamel-yaml = [ ruamel-yaml ];
    toml = [ toml ];
    tomli = [ tomli-w ];
    yaml = [ ruamel-yaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "box" ];

  meta = {
    description = "Python dictionaries with advanced dot notation access";
    homepage = "https://github.com/cdgriffith/Box";
    changelog = "https://github.com/cdgriffith/Box/blob/${version}/CHANGES.rst";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
}
