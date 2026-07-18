{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonPackage rec {
  pname = "yams";
  # nixpkgs-update: no auto update
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "Berulacks";
    repo = "yams";
    rev = version;
    sha256 = "1zkhcys9i0s6jkaz24an690rvnkv1r84jxpaa84sf46abi59ijh8";
  };

  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    pyyaml
    psutil
    python-mpd2
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "yams.scrobble" ];

  meta = {
    description = "Last.FM scrobbler for MPD";
    homepage = "https://github.com/Berulacks/yams";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ccellado ];
    mainProgram = "yams";
  };
}
