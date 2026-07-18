{
  lib,
  buildPythonPackage,
  # dependencies
  click,
  docutils,
  fetchPypi,
  itsdangerous,
  jedi,
  loro,
  markdown,
  msgspec,
  narwhals,
  packaging,
  psutil,
  pygments,
  pymdown-extensions,
  python-multipart,
  pyyaml,
  pyzmq,
  starlette,
  tomlkit,
  # build-system
  uv-build,
  uvicorn,
  # tests
  versionCheckHook,
  websockets,
}:
buildPythonPackage rec {
  pname = "marimo";
  version = "0.23.11";

  # The github archive does not include the static assets
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-8y/DCVqh5G07nPn2dymz4SHrkb//+3XzgOFEnYMoiHg=";
  };

  # The pypi archive does not contain tests so we do not use `pytestCheckHook`
  nativeCheckInputs = [
    versionCheckHook
  ];

  build-system = [ uv-build ];

  dependencies = [
    click
    docutils
    itsdangerous
    jedi
    loro
    markdown
    msgspec
    narwhals
    packaging
    psutil
    pygments
    pymdown-extensions
    python-multipart
    pyyaml
    pyzmq
    starlette
    tomlkit
    uvicorn
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "marimo" ];
  pythonRelaxDeps = [ "jedi" ];

  meta = {
    description = "Reactive Python notebook that's reproducible, git-friendly, and deployable as scripts or apps";
    homepage = "https://github.com/marimo-team/marimo";
    changelog = "https://github.com/marimo-team/marimo/releases/tag/${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      akshayka
      dmadisetti
    ];

    mainProgram = "marimo";
  };
}
