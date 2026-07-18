{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # tests
  glibcLocales,
  # dependencies
  mpmath,
  # Reverse dependency
  sage,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "sympy";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "sympy";
    repo = "sympy";
    tag = "sympy-${finalAttrs.version}";
    hash = "sha256-aSMQ/H5agjsa+Lp7o15/irLSTLtmF/VEqMCBGbXbvmM=";
  };

  # tests take ~1h
  doCheck = false;
  nativeCheckInputs = [ glibcLocales ];
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    mpmath
  ];

  pyproject = true;
  pythonImportsCheck = [ "sympy" ];

  pythonRelaxDeps = [
    "mpmath"
  ];

  passthru.tests = {
    inherit sage;
  };

  meta = {
    description = "Python library for symbolic mathematics";
    homepage = "https://www.sympy.org/";
    changelog = "https://github.com/sympy/sympy/wiki/Release-Notes-for-${finalAttrs.version}";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      GaetanLepage
    ];

    mainProgram = "isympy";
    downloadPage = "https://github.com/sympy/sympy";
    teams = [ lib.teams.sage ];
  };
})
