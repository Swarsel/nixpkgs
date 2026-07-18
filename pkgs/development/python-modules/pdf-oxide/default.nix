{
  buildPythonPackage,
  # optional-dependencies
  onnxruntime,
  pkgs,
  # tests
  pytestCheckHook,
  # build-system
  rustPlatform,
}:
buildPythonPackage (finalAttrs: {
  inherit (pkgs.pdf-oxide)
    pname
    version
    src
    cargoDeps
    ;

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  __structuredAttrs = true;

  disabledTests = [
    # AssertionError: assert (False or False or False)
    "test_version_is_038_or_newer"
    #401: two-font encrypted PDF (19203 B) is too small
    "test_issue_401_two_embedded_fonts_save_encrypted"
  ];

  optional-dependencies = {
    ocr = [ onnxruntime ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pdf_oxide" ];

  meta = pkgs.pdf-oxide.meta // {
    description = "Python bindings for the pdf_oxide library";
  };
})
