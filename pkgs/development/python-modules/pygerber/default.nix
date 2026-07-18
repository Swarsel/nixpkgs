{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  drawsvg,
  dulwich,
  # test
  filelock,
  lsprotocol,
  # dependencies
  numpy,
  pillow,
  # build-system
  poetry-core,
  pydantic,
  # optional dependencies
  pygls,
  pygments,
  pyparsing,
  pytest-asyncio,
  pytest-lsp,
  pytest-mock,
  pytest-xdist,
  pytestCheckHook,
  shapely,
  typing-extensions,
  tzlocal,
}:

buildPythonPackage rec {
  pname = "pygerber";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "Argmaster";
    repo = "pygerber";
    tag = "v${version}";
    hash = "sha256-0AoRmIN1FNlummJSHdysO2IDBHtfNPhVnh9j0lyWNFI=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-xdist
    pytest-lsp
    pytest-mock
    pytestCheckHook
    tzlocal
    drawsvg
    dulwich
    filelock
  ];

  build-system = [ poetry-core ];

  dependencies = [
    numpy
    click
    pillow
    pydantic
    pyparsing
    typing-extensions
  ];

  disabledTestPaths = [
    # require network access
    "test/gerberx3/test_assets.py"
    "test/gerberx3/test_language_server/tests.py"
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # FileNotFoundError: [Errno 2] No such file or directory: 'open'
    "test_project_render_with_file_type_tags"
  ];

  pyproject = true;
  pytestFlags = [ "--override-ini=required_plugins=" ];
  pythonImportsCheck = [ "pygerber" ];

  passthru.optional-dependencies = {
    all = [
      pygls
      lsprotocol
      drawsvg
      pygments
      shapely
    ];

    language_server = [
      pygls
      lsprotocol
    ];

    pygments = [ pygments ];
    shapely = [ shapely ];
    svg = [ drawsvg ];
  };

  meta = {
    description = "Implementation of the Gerber X3/X2 format, based on Ucamco's The Gerber Layer Format Specification";
    homepage = "https://github.com/Argmaster/pygerber";
    changelog = "https://argmaster.github.io/pygerber/stable/Changelog.html";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ clemjvdm ];
  };
}
