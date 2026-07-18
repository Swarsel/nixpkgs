{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "grasp-backend";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "karlicoss";
    repo = "grasp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4eHY58ulvLGkKHfEishRlWPI52juxWP2zzUDwRmTM/k=";
  };

  # Tests do not seem possible to run with pytest:
  # RuntimeError: ("Couldn't determine path for ", PosixPath('/build/source/tests/webdriver_utils.py'))
  doCheck = false;

  build-system = with python3Packages; [
    hatch-vcs
    hatchling
  ];

  pyproject = true;
  pythonImportsCheck = [ "grasp_backend" ];

  meta = {
    description = "Backend for grasp browser extension";
    homepage = "https://github.com/karlicoss/grasp/";
    changelog = "https://github.com/karlicoss/grasp/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hiro98 ];
    mainProgram = "grasp_backend";
  };
})
