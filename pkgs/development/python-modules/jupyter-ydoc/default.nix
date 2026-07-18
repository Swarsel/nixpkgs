{
  lib,
  fetchFromGitHub,
  # dependencies
  anyio,
  buildPythonPackage,
  # build-system
  hatch-nodejs-version,
  hatchling,
  pycrdt,
  # tests
  pycrdt-websocket,
  pytestCheckHook,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "jupyter-ydoc";
  version = "3.4.1";

  src = fetchFromGitHub {
    owner = "jupyter-server";
    repo = "jupyter_ydoc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-HlYSPlYiHyVwJhsRY10SgotKa9ejlj0hlxbS+chtaBI=";
  };

  # requires a Node.js environment
  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pycrdt-websocket
    websockets
  ];

  __structuredAttrs = true;

  build-system = [
    hatch-nodejs-version
    hatchling
  ];

  dependencies = [
    anyio
    pycrdt
  ];

  pyproject = true;
  pythonImportsCheck = [ "jupyter_ydoc" ];

  pythonRelaxDeps = [
    "pycrdt"
  ];

  meta = {
    description = "Document structures for collaborative editing using Yjs/pycrdt";
    homepage = "https://github.com/jupyter-server/jupyter_ydoc";
    changelog = "https://github.com/jupyter-server/jupyter_ydoc/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    teams = [ lib.teams.jupyter ];
  };
})
