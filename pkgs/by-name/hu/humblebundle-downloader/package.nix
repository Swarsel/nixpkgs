{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "humblebundle-downloader";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "xtream1101";
    repo = "humblebundle-downloader";
    tag = finalAttrs.version;
    hash = "sha256-fLfAGDKn6AWHJKsgQ0fBYdN6mGfZNrVs9n6Zo9VRgIY=";
  };

  build-system = with python3Packages; [
    poetry-core
  ];

  dependencies = with python3Packages; [
    parsel
    requests
  ];

  pyproject = true;

  meta = {
    description = "Download your Humble Bundle Library";
    homepage = "https://github.com/xtream1101/humblebundle-downloader";
    changelog = "https://github.com/xtream1101/humblebundle-downloader/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jopejoe1 ];
    mainProgram = "hbd";
  };
})
