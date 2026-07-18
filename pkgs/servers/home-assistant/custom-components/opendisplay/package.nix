{
  lib,
  fetchFromGitHub,
  # dependencies
  bleak,
  bleak-retry-connector,
  buildHomeAssistantComponent,
  numpy,
  # tests
  pytest-asyncio,
  pytest-homeassistant-custom-component,
  pytestCheckHook,
  python-resize-image,
  qrcode,
  requests-toolbelt,
  websocket-client,
  websockets,
}:

buildHomeAssistantComponent (finalAttrs: {
  version = "2.0.2";

  src = fetchFromGitHub {
    inherit (finalAttrs) owner;
    repo = "Home_Assistant_Integration";
    tag = finalAttrs.version;
    hash = "sha256-EmcDY31cTWK+JRErM6EWO0jrQvIaxKXgeI6i5qiwYGU=";
  };

  nativeCheckInputs = [
    pytest-asyncio
    pytest-homeassistant-custom-component
    pytestCheckHook
  ];

  dependencies = [
    bleak
    bleak-retry-connector
    numpy
    python-resize-image
    qrcode
    requests-toolbelt
    websocket-client
    websockets
  ]
  ++ qrcode.optional-dependencies.pil;

  disabledTestPaths = [
    # Probably mismatch in fontconfig priorities
    "tests/drawcustom/text_multiline_test.py::test_text_multiline_delimiter" # AssertionError: Multiline text with delimiter rendering failed
    "tests/drawcustom/text_multiline_test.py::test_text_multiline_empty_line" # AssertionError: Multiline text with empty line rendering failed
    "tests/drawcustom/text_multiline_test.py::test_text_multiline_delimiter_and_newline" # AssertionError: Multiline text with delimiter and newline rendering failed
    "tests/drawcustom/text_test.py::test_small_font_size" # AssertionError: Small font size rendering failed
    "tests/drawcustom/text_test.py::test_large_font_size" # AssertionError: Large font size rendering failed
    "tests/drawcustom/text_test.py::test_text_wrapping" # AssertionError: Text wrapping failed
    "tests/drawcustom/text_test.py::test_text_wrapping_with_anchor" # AssertionError: Text wrapping failed
    "tests/drawcustom/text_test.py::test_text_with_special_characters" # AssertionError: Special characters rendering failed
    "tests/drawcustom/text_test.py::test_text_percentage" # AssertionError: Text with percentage rendering failed
    "tests/drawcustom/text_test.py::test_text_anchors" # AssertionError: Text anchor points failed
    "tests/drawcustom/text_test.py::test_text_truncate" # AssertionError: Text truncation failed
  ];

  domain = "opendisplay";

  ignoreVersionRequirement = [
    "qrcode"
    "websocket-client"
  ];

  owner = "OpenDisplay";

  meta = {
    description = "Home Assistant Integration for OpenDisplay";
    homepage = "https://github.com/OpenDisplay/Home_Assistant_Integration";
    changelog = "https://github.com/OpenDisplay/Home_Assistant_Integration/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
