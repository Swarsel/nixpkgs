{
  lib,
  antlr4,
  buildPythonPackage,
  python,
  setuptools,
}:

buildPythonPackage rec {
  inherit (antlr4.runtime.cpp) version src;
  pname = "antlr4-python3-runtime";

  postPatch = ''
    substituteInPlace tests/TestIntervalSet.py \
      --replace "assertEquals" "assertEqual"
  '';

  # We use an asterisk because this expression is used also for old antlr
  # versions, where there the tests directory is `test` and not `tests`.
  # See e.g in package `baserow`.
  checkPhase = ''
    runHook preCheck

    pushd tests
    ${python.interpreter} run.py
    popd

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;
  sourceRoot = "${src.name}/runtime/Python3";

  meta = {
    description = "Runtime for ANTLR";
    homepage = "https://www.antlr.org/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sarahec ];
    mainProgram = "pygrun";
  };
}
