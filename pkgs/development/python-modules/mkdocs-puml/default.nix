{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  httpx,
  markdown,
  mkdocs,
  msgpack,
  poetry-core,
  pytest-httpx,
  pytestCheckHook,
  rich,
}:

buildPythonPackage rec {
  pname = "mkdocs-puml";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "MikhailKravets";
    repo = "mkdocs_puml";
    tag = "v${version}";
    hash = "sha256-DOGS2lnFIpFdpJxIw9PJ/kvtAOhVtAJOQeMR+CVjkE0=";
  };

  patches = [
    # Fix permission of copied files from the store so that they are
    # overwritable.
    ./fix-permissions.patch
  ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-httpx
  ];

  build-system = [ poetry-core ];

  dependencies = [
    httpx
    markdown
    mkdocs
    msgpack
    rich
  ];

  pyproject = true;
  pythonImportsCheck = [ "mkdocs_puml" ];

  pythonRelaxDeps = [
    "httpx"
    "rich"
  ];

  meta = {
    description = "Brings PlantUML to MkDocs";
    homepage = "https://github.com/MikhailKravets/mkdocs_puml";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
