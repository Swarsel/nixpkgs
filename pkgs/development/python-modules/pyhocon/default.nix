{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mock,
  pyparsing,
  pytestCheckHook,
  python-dateutil,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pyhocon";
  version = "0.3.63";

  src = fetchFromGitHub {
    owner = "chimpler";
    repo = "pyhocon";
    tag = finalAttrs.version;
    hash = "sha256-uguNvXBaccAUdQx1zcpn/i3jSa5Y4uWTqkFr6rI4fBc=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "pyparsing~=2.0" "pyparsing>=2.0"
  '';

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    pyparsing
    python-dateutil
  ];

  disabledTestPaths = [
    # pyparsing.exceptions.ParseException: Expected end of text, found '='
    # https://github.com/chimpler/pyhocon/issues/273
    "tests/test_tool.py"
  ];

  disabledTests = [
    # AssertionError: assert ConfigTree([(...
    "test_dict_merge"
    "test_parse_override"
    "test_include_dict"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pyhocon" ];

  meta = {
    description = "HOCON parser for Python";

    longDescription = ''
      A HOCON parser for Python. It additionally provides a tool (pyhocon) to convert
      any HOCON content into JSON, YAML and properties format.
    '';

    homepage = "https://github.com/chimpler/pyhocon/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ chreekat ];
    mainProgram = "pyhocon";
  };
})
