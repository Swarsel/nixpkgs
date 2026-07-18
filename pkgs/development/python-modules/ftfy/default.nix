{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  hatchling,
  # tests
  pytestCheckHook,
  versionCheckHook,
  # dependencies
  wcwidth,
}:

buildPythonPackage (finalAttrs: {
  pname = "ftfy";
  version = "6.3.1";

  src = fetchFromGitHub {
    owner = "rspeer";
    repo = "python-ftfy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TmwDJeUDcF+uOB2X5tMmnf9liCI9rP6dYJVmJoaqszo=";
  };

  nativeCheckInputs = [
    versionCheckHook
    pytestCheckHook
  ];

  preCheck = ''
    export PATH=$out/bin:$PATH
  '';

  build-system = [ hatchling ];
  dependencies = [ wcwidth ];

  disabledTests = [
    # https://github.com/rspeer/python-ftfy/issues/226
    "ftfy.formatting.monospaced_width"
  ];

  pyproject = true;
  pythonImportsCheck = [ "ftfy" ];

  meta = {
    description = "Given Unicode text, make its representation consistent and possibly less broken";
    homepage = "https://github.com/LuminosoInsight/python-ftfy";
    changelog = "https://github.com/rspeer/python-ftfy/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "ftfy";
  };
})
