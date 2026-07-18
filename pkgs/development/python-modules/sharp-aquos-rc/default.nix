{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyyaml,
  setuptools,
}:

buildPythonPackage rec {
  pname = "sharp-aquos-rc";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "jmoore987";
    repo = "sharp_aquos_rc";
    tag = version;
    hash = "sha256-w/XA58iT/pmNCy9up5fayjxBsevzgr8ImKgPiNtYHAM=";
  };

  nativeBuildInputs = [ setuptools ];
  propagatedBuildInputs = [ pyyaml ];
  # No tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "sharp_aquos_rc" ];

  meta = {
    description = "Control Sharp Aquos SmartTVs through the IP interface";
    homepage = "https://github.com/jmoore987/sharp_aquos_rc";
    changelog = "https://github.com/jmoore987/sharp_aquos_rc/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jamiemagee ];
  };
}
