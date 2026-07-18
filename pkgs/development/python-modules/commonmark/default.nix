{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hypothesis,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "commonmark";
  version = "0.9.1";

  src = fetchFromGitHub {
    owner = "readthedocs";
    repo = "commonmark.py";
    tag = version;
    hash = "sha256-Ui/G/VLdjWcm7YmVjZ5Q8h0DEEFqdDByre29g3zHUq4=";
  };

  nativeCheckInputs = [ hypothesis ];

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} commonmark/tests/run_spec_tests.py
    ${python.interpreter} commonmark/tests/unit_tests.py

    export PATH=$out/bin:$PATH
    cmark commonmark/tests/test.md
    cmark commonmark/tests/test.md -a
    cmark commonmark/tests/test.md -aj

    runHook postCheck
  '';

  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Python CommonMark parser ";
    homepage = "https://github.com/readthedocs/commonmark.py";
    license = lib.licenses.bsd3;
    mainProgram = "cmark";
  };
}
