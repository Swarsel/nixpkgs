{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
  versionCheckHook,
}:
python3Packages.buildPythonApplication (finalAttrs: {
  pname = "beeref";
  version = "0.3.3";

  src = fetchFromGitHub {
    owner = "rbreu";
    repo = "beeref";
    tag = "v${finalAttrs.version}";
    hash = "sha256-GtxiJKj3tlzI1kVXzJg0LNAUcodXSna17ZvAtsAEH4M=";
  };

  # Tests fail with "Fatal Python error: Aborted" due to PyQt6 GUI initialization issues in sandbox
  # Only versionCheckHook and pythonImportsCheck are used for basic validation
  nativeCheckInputs = [ versionCheckHook ];
  build-system = [ python3Packages.setuptools ];

  dependencies = with python3Packages; [
    exif
    lxml
    pyqt6
    rectangle-packer
  ];

  pyproject = true;
  pythonImportsCheck = [ "beeref" ];

  pythonRelaxDeps = [
    "lxml"
    "pyqt6"
    "rectangle-packer"
  ];

  pythonRemoveDeps = [ "pyqt6-qt6" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Reference image viewer";
    homepage = "https://beeref.org";
    changelog = "https://github.com/rbreu/beeref/blob/v${finalAttrs.version}/CHANGELOG.rst";

    license = with lib.licenses; [
      cc0
      gpl3Only
    ];

    sourceProvenance = [ lib.sourceTypes.fromSource ];
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    platforms = lib.platforms.all;
    mainProgram = "beeref";
  };
})
