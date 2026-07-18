{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  cattrs,
  flit-core,
  importlib-resources,
  jsonschema,
  pyhamcrest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "lsprotocol";
  version = "2023.0.1"; # nixpkgs-update: no auto update

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "lsprotocol";
    tag = version;
    hash = "sha256-PHjLKazMaT6W4Lve1xNxm6hEwqE3Lr2m5L7Q03fqb68=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  checkInputs = [
    importlib-resources
    jsonschema
    pyhamcrest
  ];

  preCheck = ''
    cd ../../
  '';

  build-system = [
    flit-core
  ];

  dependencies = [
    attrs
    cattrs
  ];

  disabledTests = [
    # cattrs.errors.StructureHandlerNotFoundError: Unsupported type:
    # typing.Union[str, lsprotocol.types.NotebookDocumentFilter_Type1,
    # lsprotocol.types.NotebookDocumentFilter_Type2,
    # lsprotocol.types.NotebookDocumentFilter_Type3, NoneType]. Register
    # a structure hook for it.
    "test_notebook_sync_options"
  ];

  pyproject = true;
  pythonImportsCheck = [ "lsprotocol" ];
  sourceRoot = "${src.name}/packages/python";
  passthru.skipBulkUpdate = true;

  meta = {
    description = "Python implementation of the Language Server Protocol";
    homepage = "https://github.com/microsoft/lsprotocol";
    changelog = "https://github.com/microsoft/lsprotocol/releases/tag/${src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      doronbehar
      fab
    ];
  };
}
