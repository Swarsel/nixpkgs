{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "famly-fetch";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "jacobbunk";
    repo = "famly-fetch";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MU9T8eP/LNOLAQFPOC1EEy58+kcn7G+Hh2R8wC92qnQ=";
  };

  # No tests in the repository
  doCheck = false;
  nativeInstallCheckInputs = [ versionCheckHook ];

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    click
    importlib-resources
    piexif
  ];

  pyproject = true;
  pythonImportsCheck = [ "famly_fetch" ];

  meta = {
    description = "Fetch your (kid's) images from famly.co";
    homepage = "https://github.com/jacobbunk/famly-fetch";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tlvince ];
    mainProgram = "famly-fetch";
  };
})
