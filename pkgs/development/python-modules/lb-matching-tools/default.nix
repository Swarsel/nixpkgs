{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  regex,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "lb-matching-tools";
  version = "2024.01.30.1";

  src = fetchFromGitHub {
    owner = "metabrainz";
    repo = "listenbrainz-matching-tools";
    tag = "v${version}";
    hash = "sha256-RQ4X6DKigQsNxaAWXB1meATKP+ddMUgkoAIyX8iIisU=";
  };

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ regex ];
  pyproject = true;
  pythonImportsCheck = [ "lb_matching_tools" ];

  meta = {
    description = "ListenBrainz tools for matching metadata to and from MusicBrainz";
    homepage = "https://github.com/metabrainz/listenbrainz-matching-tools";
    changelog = "https://github.com/metabrainz/listenbrainz-matching-tools/releases/tag/${src.tag}";
    license = lib.licenses.gpl2Plus;
    teams = [ lib.teams.ngi ];
  };
}
