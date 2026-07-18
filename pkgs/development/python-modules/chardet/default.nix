{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
  hypothesis,
  pytest-timeout,
  pytest-xdist,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "chardet";
  version = "6.0.0.post1";

  src = fetchFromGitHub {
    owner = "chardet";
    repo = "chardet";
    tag = finalAttrs.version;
    hash = "sha256-7G998L4VRvNiGBBNAxPJB27lI2DtL1lTteowUH2NBDk=";
  };

  nativeCheckInputs = [
    hypothesis
    pytest-timeout
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [
    hatch-vcs
    hatchling
  ];

  disabledTests = [
    # flaky; https://github.com/chardet/chardet/issues/256
    "test_detect_all_and_detect_one_should_agree"
  ];

  pyproject = true;
  pythonImportsCheck = [ "chardet" ];

  meta = {
    description = "Universal encoding detector";
    homepage = "https://github.com/chardet/chardet";
    changelog = "https://github.com/chardet/chardet/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
    mainProgram = "chardetect";
  };
})
