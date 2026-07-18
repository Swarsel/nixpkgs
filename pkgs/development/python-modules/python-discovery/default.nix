{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  filelock,
  # build-system
  hatch-vcs,
  hatchling,
  platformdirs,
  # tests
  pytest-mock,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "python-discovery";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "tox-dev";
    repo = "python-discovery";
    tag = finalAttrs.version;
    hash = "sha256-xnQWXXStdgu99riKFW4+O7tqYL4w5f7etjC872q/LWc=";
  };

  nativeCheckInputs = [
    pytest-mock
    pytestCheckHook
  ];

  __structuredAttrs = true;

  build-system = [
    hatch-vcs
    hatchling
  ];

  dependencies = [
    filelock
    platformdirs
  ];

  pyproject = true;
  pythonImportsCheck = [ "python_discovery" ];

  meta = {
    description = "Python interpreter discovery";
    homepage = "https://github.com/tox-dev/python-discovery";
    changelog = "https://github.com/tox-dev/python-discovery/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
