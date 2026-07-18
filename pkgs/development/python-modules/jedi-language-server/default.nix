{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  cattrs,
  # dependencies
  docstring-to-markdown,
  # build-system
  hatchling,
  jedi,
  lsprotocol,
  pygls,
  pyhamcrest,
  # tests
  pytestCheckHook,
  python-lsp-jsonrpc,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "jedi-language-server";
  version = "0.47.0";

  src = fetchFromGitHub {
    owner = "pappasam";
    repo = "jedi-language-server";
    tag = "v${version}";
    hash = "sha256-UXFIVj2g/s669vgS9uLH+5qFjNFoIFhS5S6XDbzRYwU=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    pyhamcrest
    python-lsp-jsonrpc
    writableTmpDirAsHomeHook
  ];

  build-system = [
    hatchling
  ];

  dependencies = [
    docstring-to-markdown
    jedi
    lsprotocol
    cattrs
    pygls
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # https://github.com/pappasam/jedi-language-server/issues/313
    "test_publish_diagnostics_on_change"
    "test_publish_diagnostics_on_save"
  ];

  pyproject = true;
  pythonImportsCheck = [ "jedi_language_server" ];

  pythonRelaxDeps = [
    "jedi"
  ];

  meta = {
    description = "Language Server for the latest version(s) of Jedi";
    homepage = "https://github.com/pappasam/jedi-language-server";
    changelog = "https://github.com/pappasam/jedi-language-server/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ doronbehar ];
    mainProgram = "jedi-language-server";
  };
}
