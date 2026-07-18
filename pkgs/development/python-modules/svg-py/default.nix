{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytestCheckHook,
  pyyaml,
}:

buildPythonPackage rec {
  pname = "svg-py";
  version = "1.10.0";

  src = fetchFromGitHub {
    owner = "orsinium-labs";
    repo = "svg.py";
    tag = version;
    hash = "sha256-ZbMDjo2p0DnLB5iwQ4J3NIP/zjPsBLq7vKStF9SzF9Y=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  build-system = [ flit-core ];

  disabledTestPaths = [
    # Tests need additional files
    "tests/test_attributes.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "svg" ];

  meta = {
    description = "Type-safe Python library to generate SVG files";
    homepage = "https://github.com/orsinium-labs/svg.py";
    changelog = "https://github.com/orsinium-labs/svg.py/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
  };
}
