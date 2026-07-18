{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  hatchling,
}:

let
  version = "1.0.0";
in
buildPythonPackage {
  inherit version;
  pname = "hatch-build-scripts";

  src = fetchFromGitHub {
    owner = "rmorshea";
    repo = "hatch-build-scripts";
    tag = "v${version}";
    hash = "sha256-umqtfUGmmZ/j/E8JY+s6REmDeTYwbcE1jZ7w4nczazs=";
  };

  build-system = [ hatchling ];
  dependencies = [ hatch-vcs ];
  pyproject = true;
  pythonImportsCheck = [ "hatch_build_scripts" ];

  meta = {
    description = "Plugin for Hatch that runs build scripts and saves their artifacts";
    homepage = "https://github.com/rmorshea/hatch-build-scripts";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ kyehn ];
  };
}
