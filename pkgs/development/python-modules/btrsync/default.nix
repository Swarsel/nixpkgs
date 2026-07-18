{
  lib,
  fetchFromGitHub,
  btrfs-progs,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "btrsync";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "andreittr";
    repo = "btrsync";
    tag = "v${version}";
    hash = "sha256-1LpHO70Yli9VG1UeqPZWM2qUMUbSbdgNP/r7FhUY/h4=";
  };

  propagatedBuildInputs = [ btrfs-progs ];
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "btrsync" ];

  meta = {
    description = "Btrfs replication made easy";
    homepage = "https://github.com/andreittr/btrsync";
    changelog = "https://github.com/andreittr/btrsync/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ bcyran ];
    mainProgram = "btrsync";
  };
}
