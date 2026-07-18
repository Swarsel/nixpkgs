{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "wayback-machine-archiver";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "agude";
    repo = "wayback-machine-archiver";
    tag = "v${finalAttrs.version}";
    hash = "sha256-YIVrz+TUx2SFIDOCR/P+2R3jpXN1K+SM2xyiVL2Hjfo=";
  };

  nativeCheckInputs = with python3Packages; [
    pytestCheckHook
    requests-mock
  ];

  __structuredAttrs = true;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    requests
    python-dotenv
  ];

  pyproject = true;
  pythonImportsCheck = [ "wayback_machine_archiver" ];

  meta = {
    description = "Python script to submit web pages to the Wayback Machine for archiving";
    homepage = "https://github.com/agude/wayback-machine-archiver";
    changelog = "https://github.com/agude/wayback-machine-archiver/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dandellion ];
    mainProgram = "archiver";
  };
})
