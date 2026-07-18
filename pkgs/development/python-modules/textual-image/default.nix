{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pillow,
  # tests
  pytestCheckHook,
  # dependencies
  rich,
  # build-system
  setuptools,
  syrupy,
}:

buildPythonPackage (finalAttrs: {
  pname = "textual-image";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "lnqs";
    repo = "textual-image";
    tag = "v${finalAttrs.version}";
    hash = "sha256-W0f9ZnSZ58XqiPnr9SZEv22EE4yCsvXcgNA8eJebJQo=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    syrupy
  ];

  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    pillow
    rich
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # AssertionError: assert [+ received] == [- snapshot]
    "test_render"
  ];

  pyproject = true;
  pythonImportsCheck = [ "textual_image" ];

  meta = {
    description = "Render images in the terminal with Textual and rich";
    homepage = "https://github.com/lnqs/textual-image/";
    changelog = "https://github.com/lnqs/textual-image/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ gaelj ];
  };
})
