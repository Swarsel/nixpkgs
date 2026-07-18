{
  lib,
  fetchFromGitHub,
  beets-minimal,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  setuptools,
  writableTmpDirAsHomeHook,
  yt-dlp,
  ytmusicapi,
}:
buildPythonPackage rec {
  pname = "beets-ytimport";
  version = "1.13.0";

  src = fetchFromGitHub {
    owner = "mgoltzsche";
    repo = "beets-ytimport";
    tag = "v${version}";
    hash = "sha256-EwSL1rBEPTcMfrlTkQcqRuhR8OtibBZqA0qQz4+qLEw=";
  };

  nativeBuildInputs = [
    beets-minimal
  ];

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    ytmusicapi
    yt-dlp
  ];

  pyproject = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Beets plugin to import music from Youtube and SoundCloud";
    homepage = "https://github.com/mgoltzsche/beets-ytimport";
    changelog = "https://github.com/mgoltzsche/beets-ytimport/releases/tag/v${version}";
    license = [ lib.licenses.asl20 ];
    maintainers = with lib.maintainers; [ pyrox0 ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
