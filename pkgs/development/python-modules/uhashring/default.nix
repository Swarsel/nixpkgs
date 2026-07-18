{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytestCheckHook,
  python-memcached,
}:
buildPythonPackage rec {
  pname = "uhashring";
  version = "2.4";

  src = fetchFromGitHub {
    owner = "ultrabug";
    repo = "uhashring";
    tag = version;
    hash = "sha256-6zNPExbcwTUne0lT8V6xp2Gf6J1VgG7Q93qizVOAc+k=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    python-memcached
  ];

  build-system = [
    hatchling
  ];

  pyproject = true;

  pythonImportsCheck = [
    "uhashring"
  ];

  meta = {
    description = "Full featured consistent hashing python library compatible with ketama";
    homepage = "https://github.com/ultrabug/uhashring";
    changelog = "https://github.com/ultrabug/uhashring/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ typedrat ];
  };
}
