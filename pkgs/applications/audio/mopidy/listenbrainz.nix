{
  lib,
  fetchFromGitHub,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-listenbrainz";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "suaviloquence";
    repo = "mopidy-listenbrainz";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kYZgG2KQMTxMR8tdwwCKkfexDcxcndXG9LSdlnoN/CY=";
  };

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.musicbrainzngs
  ];

  pyproject = true;

  meta = {
    description = "Mopidy extension for recording played tracks and getting recommendations to Listenbrainz, a libre alternative to Last.fm";
    homepage = "https://github.com/suaviloquence/mopidy-listenbrainz";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ bohanubis ];
  };
})
