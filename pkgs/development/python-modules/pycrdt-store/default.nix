{
  lib,
  fetchFromGitHub,
  # dependencies
  anyio,
  buildPythonPackage,
  # build-system
  hatchling,
  pycrdt,
  # tests
  pytestCheckHook,
  sqlite-anyio,
  trio,
}:

buildPythonPackage (finalAttrs: {
  pname = "pycrdt-store";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "y-crdt";
    repo = "pycrdt-store";
    tag = finalAttrs.version;
    hash = "sha256-ggfk9MT/thBKHStToYwSDT4+ZL7mqveg9XDEXLAViU8=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    trio
  ];

  __structuredAttrs = true;

  build-system = [
    hatchling
  ];

  dependencies = [
    anyio
    pycrdt
    sqlite-anyio
  ];

  disabledTestMarks = [ "flaky" ];
  pyproject = true;
  pythonImportsCheck = [ "pycrdt.store" ];

  meta = {
    description = "Persistent storage for pycrdt";
    homepage = "https://github.com/y-crdt/pycrdt-store";
    changelog = "https://github.com/y-crdt/pycrdt-store/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ sarahec ];
  };
})
