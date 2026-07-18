{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  more-itertools,
  pytestCheckHook,
  pyyaml,
}:
let
  version = "3.2.1";
in
buildPythonPackage {
  inherit version;
  pname = "tap.py";

  src = fetchPypi {
    inherit version;
    hash = "sha256-0DyeavClb62ZTxxp8UBB5naBHXPu7vIL9Ad8Q9Yh1gg=";
    pname = "tap_py";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    hatchling
  ];

  optional-dependencies = {
    yaml = [
      pyyaml
      more-itertools
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "tap" ];

  meta = {
    description = "Set of tools for working with the Test Anything Protocol (TAP) in Python";
    homepage = "https://github.com/python-tap/tappy";
    changelog = "https://tappy.readthedocs.io/en/latest/releases.html";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "tappy";
  };
}
