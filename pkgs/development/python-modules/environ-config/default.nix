{
  lib,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  hatch-fancy-pypi-readme,
  hatch-vcs,
  hatchling,
  importlib-metadata,
  moto,
  pytestCheckHook,
}:
buildPythonPackage rec {
  pname = "environ-config";
  version = "24.1.0";

  src = fetchFromGitHub {
    owner = "hynek";
    repo = "environ-config";
    tag = version;
    hash = "sha256-XiJNLQgKhf9hXQfIMsfiEaHx7IHaExhphpYfOBgIT+s=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    moto
  ];

  build-system = [
    hatchling
    hatch-vcs
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    attrs
    importlib-metadata
  ];

  pyproject = true;
  pythonImportsCheck = [ "environ" ];

  meta = {
    description = "Python Application Configuration With Environment Variables";
    homepage = "https://github.com/hynek/environ-config";
    changelog = "https://github.com/hynek/environ-config/releases/tag/${version}";
    license = lib.licenses.apsl20;
    maintainers = with lib.maintainers; [ lykos153 ];
  };
}
