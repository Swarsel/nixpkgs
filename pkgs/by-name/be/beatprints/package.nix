{
  lib,
  fetchFromGitHub,
  python3Packages,
}:
python3Packages.buildPythonApplication rec {
  pname = "BeatPrints";
  version = "1.1.6";

  src = fetchFromGitHub {
    owner = "TrueMyst";
    repo = "BeatPrints";
    rev = "v${version}";
    hash = "sha256-ExeNNN2ce3XB9dpNR4RUZTXWVI0dPdFT7/FvSFAWBw4=";
  };

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    requests
    pylette
    lrclibapi
    fonttools
    questionary
    rich
    toml
    pillow
    spotipy
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "Pillow"
    "rich"
  ];

  meta = {
    description = "Create eye-catching, Pinterest-style music posters effortlessly";

    longDescription = ''
      Create eye-catching, Pinterest-style music posters effortlessly. BeatPrints integrates with Spotify and LRClib API to help you design custom posters for your favorite tracks or albums. 🍀
    '';

    homepage = "https://beatprints.readthedocs.io";
    changelog = "https://github.com/TrueMyst/BeatPrints/releases/tag/v${version}";
    license = lib.licenses.cc-by-nc-sa-40;
    maintainers = with lib.maintainers; [ DataHearth ];
    platforms = lib.platforms.all;
    mainProgram = "beatprints";
  };
}
