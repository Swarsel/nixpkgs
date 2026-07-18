{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  six,
}:

buildPythonPackage rec {
  pname = "ush";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "tarruda";
    repo = "python-ush";
    rev = version;
    hash = "sha256-a6ICbd8647DRtuHl2vs64bsChUjlpuWHV1ipBdFA600=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    six
  ];

  build-system = [ setuptools ];

  disabledTestPaths = [
    # seems to be outdated?
    "tests/test_glob.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ush" ];

  meta = {
    description = "Powerful API for invoking with external commands";
    homepage = "https://github.com/tarruda/python-ush";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
