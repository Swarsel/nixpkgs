{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  hatch-vcs,
  # build-system
  hatchling,
  # dependencies
  pyudev,
}:

buildPythonPackage rec {
  pname = "rtslib-fb";
  version = "2.2.4";

  src = fetchFromGitHub {
    owner = "open-iscsi";
    repo = "rtslib-fb";
    tag = "v${version}";
    hash = "sha256-iDnirxx+gY2vg63IevI7qmfi4l79QXaKQc/TckjG7xE=";
  };

  # No tests
  doCheck = false;

  build-system = [
    hatchling
    hatch-vcs
  ];

  dependencies = [
    pyudev
  ];

  pyproject = true;

  meta = {
    description = "Python object API for managing the Linux LIO kernel target";
    homepage = "https://github.com/open-iscsi/rtslib-fb";
    changelog = "https://github.com/open-iscsi/rtslib-fb/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "targetctl";
  };
}
