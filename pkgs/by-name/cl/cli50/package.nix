{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "cli50";
  version = "8.0.1";

  src = fetchFromGitHub {
    owner = "cs50";
    repo = "cli50";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0gu31NPql8pFPN4jFbPwYkQmF/rbrAai6EY1ZVfXLew=";
  };

  nativeCheckInputs = [ versionCheckHook ];

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = with python3Packages; [
    inflect
    packaging
    requests
    tzlocal
  ];

  pyproject = true;
  pythonImportsCheck = [ "cli50" ];

  # no python tests
  meta = {
    description = "Mount directories into cs50/cli containers";
    homepage = "https://cs50.readthedocs.io/cli50/";
    changelog = "https://github.com/cs50/cli50/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ethancedwards8 ];
    platforms = lib.platforms.unix;
    mainProgram = "cli50";
    downloadPage = "https://github.com/cs50/cli50";
  };
})
