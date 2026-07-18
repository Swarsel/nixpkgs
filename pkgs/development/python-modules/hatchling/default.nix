{
  lib,
  # tests
  build,
  buildPythonPackage,
  # runtime
  editables,
  fetchPypi,
  packaging,
  pathspec,
  pluggy,
  python,
  requests,
  trove-classifiers,
  virtualenv,
}:

buildPythonPackage (finalAttrs: {
  pname = "hatchling";
  version = "1.30.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-7uT9RTV/cuuz16QuXXLPteKe1CbXnog2KIkmxCWNXy4=";
  };

  # tries to fetch packages from the internet
  doCheck = false;

  # listed in /backend/tests/downstream/requirements.txt
  nativeCheckInputs = [
    build
    requests
    virtualenv
  ];

  preCheck = ''
    export HOME=$(mktemp -d)
  '';

  checkPhase = ''
    runHook preCheck
    ${python.interpreter} tests/downstream/integrate.py
    runHook postCheck
  '';

  # listed in backend/pyproject.toml
  dependencies = [
    editables
    packaging
    pathspec
    pluggy
    trove-classifiers
  ];

  pyproject = true;

  pythonImportsCheck = [
    "hatchling"
    "hatchling.build"
  ];

  meta = {
    description = "Modern, extensible Python build backend";
    homepage = "https://hatch.pypa.io/latest/";
    changelog = "https://github.com/pypa/hatch/releases/tag/hatchling-v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      hexa
      ofek
    ];

    mainProgram = "hatchling";
  };
})
