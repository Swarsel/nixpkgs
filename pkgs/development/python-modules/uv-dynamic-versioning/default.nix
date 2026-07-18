{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  dunamai,
  # tests
  gitpython,
  # build-system
  hatchling,
  jinja2,
  pytestCheckHook,
  tomlkit,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage rec {
  pname = "uv-dynamic-versioning";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "ninoseki";
    repo = "uv-dynamic-versioning";
    tag = "v${version}";
    hash = "sha256-MI4LRo9XDmafXQ/xN1G8vtrBVE20qviwspMo5vIabFI=";
    # Tests perform mock operations on the local repo
    leaveDotGit = true;
  };

  nativeCheckInputs = [
    gitpython
    pytestCheckHook
    writableTmpDirAsHomeHook
  ];

  preCheck = ''
    git config --global user.email "nobody@example.com"
    git config --global user.name "Nobody"
  '';

  build-system = [
    hatchling
  ];

  dependencies = [
    dunamai
    hatchling
    jinja2
    tomlkit
  ];

  pyproject = true;

  pythonImportsCheck = [
    "uv_dynamic_versioning"
  ];

  setupHook = ./setup-hook.sh;

  meta = {
    description = "Dynamic versioning based on VCS tags for uv/hatch project";
    homepage = "https://github.com/ninoseki/uv-dynamic-versioning";
    changelog = "https://github.com/ninoseki/uv-dynamic-versioning/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
}
