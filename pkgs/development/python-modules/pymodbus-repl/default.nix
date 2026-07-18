{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  poetry-core,
  prompt-toolkit,
  pygments,
  pymodbus,
  pymodbus-repl,
  pytest-cov-stub,
  pytestCheckHook,
  tabulate,
  typer,
  doCheck ? false, # cyclic dependency with pymodbus
}:

buildPythonPackage rec {
  inherit doCheck;
  pname = "pymodbus-repl";
  version = "2.0.5";

  src = fetchFromGitHub {
    owner = "pymodbus-dev";
    repo = "repl";
    tag = version;
    hash = "sha256-jGoYp2nDWMWMX8n0aaG/YP+rQcj2npFbhdy7T1qxByc=";
  };

  nativeCheckInputs = [
    pymodbus
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    aiohttp
    prompt-toolkit
    pygments
    tabulate
    typer
  ];

  pyproject = true;
  pythonImportsCheck = [ "pymodbus_repl" ];

  pythonRelaxDeps = [
    "tabulate"
    "typer"
  ];

  passthru.tests = {
    # currently expected to fail: https://github.com/pymodbus-dev/repl/pull/26
    pytest = pymodbus-repl.override { doCheck = true; };
  };

  meta = {
    description = "REPL client and server for pymodbus";
    homepage = "https://github.com/pymodbus-dev/repl";
    changelog = "https://github.com/pymodbus-dev/repl/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
