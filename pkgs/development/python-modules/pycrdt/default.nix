{
  lib,
  fetchFromGitHub,
  # dependencies
  anyio,
  buildPythonPackage,
  nix-update-script,
  # tests
  objsize,
  pydantic,
  pytestCheckHook,
  # nativeBuildInputs
  rustPlatform,
  trio,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycrdt";
  version = "0.14.1";

  src = fetchFromGitHub {
    owner = "y-crdt";
    repo = "pycrdt";
    tag = finalAttrs.version;
    hash = "sha256-60fRju7VwxaEw5KHcpBt9D0ooAXucckMsvBC5KW2uvg=";
  };

  postPatch = ''
    cp ${./Cargo.lock} Cargo.lock
  '';

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  nativeCheckInputs = [
    anyio
    objsize
    pydantic
    pytestCheckHook
    trio
  ];

  __structuredAttrs = true;
  cargoDeps = rustPlatform.importCargoLock { lockFile = ./Cargo.lock; };
  dependencies = [ anyio ];
  pyproject = true;

  pytestFlags = [
    "-Wignore::pytest.PytestUnknownMarkWarning" # requires unpackaged pytest-mypy-testing
  ];

  pythonImportsCheck = [ "pycrdt" ];
  passthru.updateScript = nix-update-script { extraArgs = [ "--generate-lockfile" ]; };

  meta = {
    description = "CRDTs based on Yrs";
    homepage = "https://github.com/jupyter-server/pycrdt";
    changelog = "https://github.com/jupyter-server/pycrdt/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    teams = [ lib.teams.jupyter ];
  };
})
