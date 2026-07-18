{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  python,
  setuptools,
}:

let
  version = "2026.4.4";
in
buildPythonPackage {
  inherit version;
  pname = "regex";

  src = fetchFromGitHub {
    owner = "mrabarnett";
    repo = "mrab-regex";
    tag = version;
    hash = "sha256-vLhukoQc50XOgv74hBQS36w+T+27y5GTTDetZ2JV8r4=";
  };

  preCheck = ''
    rm regex/__init__.py
  '';

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} -m unittest ./regex/tests/test_regex.py

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "regex" ];

  meta = {
    description = "Alternative regular expression module, to replace re";
    homepage = "https://github.com/mrabarnett/mrab-regex";

    license = [
      lib.licenses.asl20
      lib.licenses.cnri-python
    ];

    maintainers = [ lib.maintainers.dwoffinden ];
  };
}
