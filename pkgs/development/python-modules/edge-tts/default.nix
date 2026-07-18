{
  lib,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  certifi,
  nix-update-script,
  setuptools,
  tabulate,
  typing-extensions,
  wheel,
}:

buildPythonPackage rec {
  pname = "edge-tts";
  version = "7.2.8";

  src = fetchFromGitHub {
    owner = "rany2";
    repo = "edge-tts";
    tag = version;
    hash = "sha256-Zjng/7ALTjmDS4ubSFWoBJQ8TNsc2Ijl9V3jSyKifMc=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    aiohttp
    certifi
    tabulate
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "edge_tts" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Microsoft Edge text-to-speech service WITHOUT Edge, Windows and API keys";

    longDescription = ''
      `edge-tts` is a Python module that allows you to use Microsoft
      Edge's online text-to-speech service from within your Python
      code or using the provided `edge-tts` or `edge-playback`
      command.
    '';

    homepage = "https://github.com/rany2/edge-tts";

    license = with lib.licenses; [
      mit # `src/edge_tts/srt_composer.py` only
      lgpl3Plus # All remaining files
    ];

    maintainers = with lib.maintainers; [ yiyu ];
    mainProgram = "edge-tts";
  };
}
