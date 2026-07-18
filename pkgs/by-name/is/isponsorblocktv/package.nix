{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "isponsorblocktv";
  version = "2.6.1";

  src = fetchFromGitHub {
    owner = "dmunozv04";
    repo = "iSponsorBlockTV";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AGjLehhGYz8FyojSFmSYKLCkHAExtpQiukQnTNt1YoY=";
  };

  patches = [
    # Port iSponsorBlockTV to pyytlounge v3
    (fetchpatch {
      hash = "sha256-v5YXfKUPTzpZPIkVSQF2VUe9EvclAH+kJyiiyUEe/HM=";
      url = "https://github.com/ameertaweel/iSponsorBlockTV/commit/1809ca5a0d561bc9326a51e82118f290423ed3e6.patch";
    })
  ];

  build-system = with python3Packages; [
    hatchling
    hatch-requirements-txt
  ];

  dependencies = with python3Packages; [
    aiohttp
    appdirs
    async-cache
    pyytlounge
    rich-click
    rich
    ssdp
    textual-slider
    textual
    xmltodict
  ];

  pyproject = true;
  # all dependencies are pinned to exact version numbers
  pythonRelaxDeps = true;

  meta = {
    description = "SponsorBlock client for all YouTube TV clients";
    homepage = "https://github.com/dmunozv04/iSponsorBlockTV";
    changelog = "https://github.com/dmunozv04/iSponsorBlockTV/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ lukegb ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "iSponsorBlockTV";
  };
})
