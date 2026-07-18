{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  poetry-core,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage {
  pname = "hcs-utils";
  version = "2.1.0";

  src = fetchFromGitLab {
    owner = "hcs";
    repo = "hcs_utils";
    rev = "77668de42895dedb6b4baddf4207f331776de897"; # No tags for 2.1
    hash = "sha256-T0a2lYi3umRZQInEsxnLf5p6+IxkUmGJhgW8l2ESDd0=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    poetry-core
  ];

  dependencies = [
    six
  ];

  disabledTests = [
    "test_expand" # It depends on FHS
    "test_blocking" # flaky, depends on comparing running time w/ magic value
  ];

  pyproject = true;

  meta = {
    description = "Library collecting some useful snippets";
    homepage = "https://gitlab.com/hcs/hcs_utils";
    license = lib.licenses.isc;
    maintainers = [ ];
  };
}
