{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pglast";
  version = "7.13";

  src = fetchFromGitHub {
    owner = "lelit";
    repo = "pglast";
    tag = "v${version}";
    hash = "sha256-q5QiP8UPQQnG2Ehgj9hngXnhCKvZyCy8mKA0rzWM7EY=";
    fetchSubmodules = true;
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail cython==3.2.3 cython \
      --replace-fail setuptools==80.9.0 setuptools
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  preCheck = ''
    # import from $out
    rm -r pglast
  '';

  build-system = [
    cython
    setuptools
  ];

  pyproject = true;

  pythonImportsCheck = [
    "pglast"
    "pglast.parser"
  ];

  meta = {
    description = "PostgreSQL Languages AST and statements prettifier";
    homepage = "https://github.com/lelit/pglast";
    changelog = "https://github.com/lelit/pglast/blob/v${version}/CHANGES.rst";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "pgpp";
  };
}
