{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  click,
  ordered-set,
  pillow,
  # build-system
  setuptools,
  setuptools-dso,
  sortedcollections,
}:

buildPythonPackage rec {
  pname = "tilequant";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "SkyTemple";
    repo = "tilequant";
    tag = version;
    hash = "sha256-MgyKLwVdL2DRR8J88q7Q57rQiX4FTOlQ5rTY3UuhaJM=";
    # Fetch tilequant source files
    fetchSubmodules = true;
  };

  doCheck = false; # there are no tests

  build-system = [
    setuptools
    setuptools-dso
  ];

  dependencies = [
    click
    ordered-set
    pillow
    sortedcollections
    setuptools-dso
  ];

  pyproject = true;
  pythonImportsCheck = [ "tilequant" ];

  pythonRelaxDeps = [
    "click"
  ];

  meta = {
    description = "Tool for quantizing image colors using tile-based palette restrictions";
    homepage = "https://github.com/SkyTemple/tilequant";
    changelog = "https://github.com/SkyTemple/tilequant/releases/tag/${version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ marius851000 ];
    mainProgram = "tilequant";
  };
}
