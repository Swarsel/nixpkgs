{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "redlist";
  version = "0-unstable-2026-01-30";

  src = fetchFromGitHub {
    owner = "Laharah";
    repo = "redlist";
    rev = "3d465a12d79331eefde52351b441d8e0875f93e3";
    hash = "sha256-eROvTs4WCVeXE2+4FICC9Rl5bjIkf0E5sYvqCaskXEw=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '"pytest-runner"' ""
  '';

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies =
    with python3Packages;
    [
      aiohttp
      beets
      humanize
      confuse
      pynentry
      deluge-client
      cryptography
    ]
    ++ aiohttp.optional-dependencies.speedups;

  pyproject = true;

  meta = {
    description = "Convert Spotify playlists to local m3u's and fill the gaps";
    homepage = "https://github.com/Laharah/redlist";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ lilahummel ];
    mainProgram = "redlist";
  };
})
