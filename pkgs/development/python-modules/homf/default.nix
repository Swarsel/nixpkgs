{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  callPackage,
  hatchling,
  packaging,
  # pytestCheckHook,
  versionCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "homf";
  version = "1.1.1";

  src = fetchFromGitHub {
    owner = "duckinator";
    repo = "homf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fDH6uJ2d/Jsnuudv+Qlv1tr3slxOJWh7b4smGS32n9A=";
  };

  # There are currently no checks which do not require network access, which breaks the check hook somehow?
  # nativeCheckInputs = [ pytestCheckHook ];
  # disabledTestMarks = [ "network" ];
  nativeBuildInputs = [ versionCheckHook ];
  build-system = [ hatchling ];
  dependencies = [ packaging ];
  pyproject = true;

  pythonImportsCheck = [
    "homf"
    "homf.api"
    "homf.api.github"
    "homf.api.pypi"
  ];

  pythonRelaxDeps = [ "packaging" ];
  # (Ab)using `callPackage` as a fix-point operator, so tests can use the `homf` drv
  passthru.tests = callPackage ./tests.nix { };

  meta = {
    description = "Asset download tool for GitHub Releases, PyPi, etc";
    homepage = "https://github.com/duckinator/homf";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ nicoo ];
    mainProgram = "homf";
  };
})
