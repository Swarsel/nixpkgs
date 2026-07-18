{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "gazelle-origin";
  version = "3.0.0";

  src = fetchFromGitHub {
    # Use the spinfast319 fork, since it seems that upstream
    # at <https://github.com/x1ppy/gazelle-origin> is inactive
    owner = "spinfast319";
    repo = "gazelle-origin";
    tag = version;
    hash = "sha256-+yMKnfG2f+A1/MxSBFLaHfpCgI2m968iXqt+2QanM/c=";
  };

  dependencies = with python3Packages; [
    bencoder
    pyyaml
    requests
  ];

  format = "setuptools";
  pythonImportsCheck = [ "gazelleorigin" ];

  meta = {
    description = "Tool for generating origin files using the API of Gazelle-based torrent trackers";
    homepage = "https://github.com/spinfast319/gazelle-origin";
    # TODO license is unspecified in the upstream, as well as the fork
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ somasis ];
    mainProgram = "gazelle-origin";
  };
}
