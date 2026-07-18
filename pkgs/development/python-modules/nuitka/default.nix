{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  isPyPy,
  ordered-set,
  python,
  setuptools,
  wheel,
  zstandard,
}:

buildPythonPackage rec {
  pname = "nuitka";
  version = "2.8.10";

  src = fetchFromGitHub {
    owner = "Nuitka";
    repo = "Nuitka";
    tag = version;
    hash = "sha256-+CevWpYvqY3SX3/QE7SPlbsFtXkdlNTg9m91VtZCHvM=";
  };

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} tests/basics/run_all.py search

    runHook postCheck
  '';

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    ordered-set
    zstandard
  ];

  # Requires CPython
  disabled = isPyPy;
  pyproject = true;
  pythonImportsCheck = [ "nuitka" ];

  meta = {
    description = "Python compiler with full language support and CPython compatibility";
    homepage = "https://nuitka.net/";
    license = lib.licenses.asl20;
    # never built on darwin since first introduction in nixpkgs
    broken = stdenv.hostPlatform.isDarwin;
  };
}
