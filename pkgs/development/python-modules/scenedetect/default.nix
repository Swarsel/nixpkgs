{
  lib,
  fetchFromGitHub,
  av,
  buildPythonPackage,
  click,
  numpy,
  opencv-python,
  platformdirs,
  pytestCheckHook,
  setuptools,
  tqdm,
  versionCheckHook,
}:
let
  testsResources = fetchFromGitHub {
    hash = "sha256-7ws7F7CkEJAa0PgfMEOwnpF4Xl2BQCn9+qFQb5MMlZ0=";
    owner = "Breakthrough";
    repo = "PySceneDetect";
    rev = "94389267a344785643980a2e0bb18179dcca01d3";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "scenedetect";
  version = "0.6.7.1";

  src = fetchFromGitHub {
    owner = "Breakthrough";
    repo = "PySceneDetect";
    tag = "v${finalAttrs.version}-release";
    hash = "sha256-bLR04wn4O23fHC12ZvWwDI7gLGvMhm+YnBOy4zYMPSM=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    versionCheckHook
  ];

  preCheck = ''
    cp -r ${testsResources}/tests/resources tests/
    chmod -R +w tests/resources
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    av
    click
    numpy
    opencv-python
    platformdirs
    tqdm
  ];

  pyproject = true;
  pythonImportsCheck = [ "scenedetect" ];

  pythonRelaxDeps = [
    "click"
  ];

  versionCheckProgramArg = "version";

  meta = {
    description = "Python and OpenCV-based scene cut/transition detection program & library";
    homepage = "https://www.scenedetect.com";
    changelog = "https://github.com/Breakthrough/PySceneDetect/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ DataHearth ];
    mainProgram = "scenedetect";
  };
})
