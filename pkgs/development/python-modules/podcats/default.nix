{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flask,
  humanize,
  mutagen,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "podcats";
  version = "0.6.3";

  src = fetchFromGitHub {
    owner = "jkbrzt";
    repo = "podcats";
    tag = finalAttrs.version;
    hash = "sha256-1Jg9bR/3qMim3q5qVwUVbxeLNaXaCU6SplBUaRXeLpo=";
  };

  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    flask
    humanize
    mutagen
  ];

  pyproject = true;
  pythonImportsCheck = [ "podcats" ];

  meta = {
    description = "Generates RSS feeds for podcast episodes from local audio files";
    homepage = "https://github.com/jkbrzt/podcats";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ drawbu ];
    mainProgram = "podcats";
  };
})
