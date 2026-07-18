{
  lib,
  fetchFromGitHub,
  anyio,
  async-generator,
  buildPythonPackage,
  cpyparsing,
  ipykernel,
  mypy,
  pexpect,
  prompt-toolkit,
  pygments,
  pytestCheckHook,
  pythonAtLeast,
  setuptools,
  tkinter,
  tstr,
  watchdog,
}:

buildPythonPackage rec {
  pname = "coconut";
  version = "3.2.0";

  src = fetchFromGitHub {
    owner = "evhub";
    repo = "coconut";
    tag = "v${version}";
    hash = "sha256-3L5n0nOE8NMXw2tPWjxDCWnHH94yecdnjQ+GBsxt08c=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    anyio
    async-generator
    cpyparsing
    ipykernel
    mypy
    pygments
    prompt-toolkit
    setuptools
    tstr
    watchdog
  ];

  nativeCheckInputs = [
    pexpect
    pytestCheckHook
    tkinter
  ];

  disabled = pythonAtLeast "3.13";
  # Currently most tests have performance issues
  enabledTestPaths = [ "coconut/tests/constants_test.py" ];
  pyproject = true;
  pythonImportsCheck = [ "coconut" ];

  meta = {
    description = "Simple, elegant, Pythonic functional programming";
    homepage = "http://coconut-lang.org/";
    changelog = "https://github.com/evhub/coconut/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fabianhjr ];
  };
}
