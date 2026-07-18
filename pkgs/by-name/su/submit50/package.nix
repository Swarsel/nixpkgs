{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "submit50";
  version = "3.2.1";

  src = fetchFromGitHub {
    owner = "cs50";
    repo = "submit50";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D71d8f2XfLrsDRBuEZK7B96UTUkJLkHsCWchDNO8epI=";
  };

  nativeCheckInputs = [ versionCheckHook ];

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    lib50
    packaging
    pytz
    requests
    termcolor
  ];

  pyproject = true;
  pythonImportsCheck = [ "submit50" ];

  # no python tests
  meta = {
    description = "Tool for submitting student CS50 code";
    homepage = "https://cs50.readthedocs.io/submit50/";
    changelog = "https://github.com/cs50/submit50/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "submit50";
    downloadPage = "https://github.com/cs50/submit50";
  };
})
