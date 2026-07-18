{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  colorama,
  # build-system
  flit-core,
  httpx,
  # tests
  pytestCheckHook,
  sphinx,
  starlette,
  uvicorn,
  watchfiles,
  websockets,
}:

buildPythonPackage rec {
  pname = "sphinx-autobuild";
  version = "2025.08.25";

  src = fetchFromGitHub {
    owner = "sphinx-doc";
    repo = "sphinx-autobuild";
    tag = version;
    hash = "sha256-JfhLC1924bU1USvoYwluFGdxxahS+AfRSHnGlLfE0NY=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ flit-core ];

  dependencies = [
    colorama
    httpx
    sphinx
    starlette
    uvicorn
    watchfiles
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "sphinx_autobuild" ];

  meta = {
    description = "Rebuild Sphinx documentation on changes, with live-reload in the browser";
    homepage = "https://github.com/sphinx-doc/sphinx-autobuild";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ holgerpeters ];
    mainProgram = "sphinx-autobuild";
  };
}
