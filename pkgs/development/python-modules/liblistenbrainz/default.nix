{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  requests,
  requests-mock,
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "liblistenbrainz";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "metabrainz";
    repo = "liblistenbrainz";
    tag = version;
    hash = "sha256-fZgIVGDUJ4Dh/7CIOugvpRP7FoijpsgA3bBKJMmDd7o=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    requests-mock
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "liblistenbrainz" ];

  meta = {
    description = "Simple ListenBrainz client library for Python";
    homepage = "https://github.com/metabrainz/liblistenbrainz";
    changelog = "https://github.com/metabrainz/liblistenbrainz/releases/tag/${src.tag}";
    license = lib.licenses.gpl3Plus;
    teams = [ lib.teams.ngi ];
  };
}
