{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
}:

buildPythonPackage rec {
  pname = "dungeon-eos";
  version = "0.0.5";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "dungeon-eos";
    rev = version;
    hash = "sha256-Z1fGtslXP8zcZmVeWjRrbcM2ZJsfbrWjpLWZ49uSCRY=";
  };

  doCheck = false; # there are no tests
  format = "setuptools";
  pythonImportsCheck = [ "dungeon_eos" ];

  meta = {
    description = "Package that simulates PMD EoS dungeon generation";
    homepage = "https://github.com/SkyTemple/dungeon-eos";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
  };
}
