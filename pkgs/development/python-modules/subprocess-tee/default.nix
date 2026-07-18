{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  enrich,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "subprocess-tee";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "pycontribs";
    repo = "subprocess-tee";
    tag = "v${version}";
    hash = "sha256-rfI4UZdENfSQ9EbQeldv6DDGIQe5yMjboGTCOwed1AU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    enrich
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  disabledTests = [
    # cyclic dependency on `molecule` (see https://github.com/pycontribs/subprocess-tee/issues/50)
    "test_molecule"
    # duplicates in console output, rich issue
    "test_rich_console_ex"
  ];

  pyproject = true;
  pythonImportsCheck = [ "subprocess_tee" ];

  meta = {
    description = "Subprocess.run drop-in replacement that supports a tee mode";
    homepage = "https://github.com/pycontribs/subprocess-tee";
    changelog = "https://github.com/pycontribs/subprocess-tee/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ putchar ];
  };
}
