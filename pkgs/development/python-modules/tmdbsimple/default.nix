{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "tmdbsimple";
  version = "2.9.6";

  src = fetchFromGitHub {
    owner = "celiao";
    repo = "tmdbsimple";
    tag = finalAttrs.version;
    hash = "sha256-ooyfwRCvH980gym8ujpLxbmR7FYfi59gGXqT8K40pNw=";
  };

  # The tests require an internet connection and an API key
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ requests ];
  pyproject = true;
  pythonImportsCheck = [ "tmdbsimple" ];

  meta = {
    description = "Wrapper for The Movie Database API v3";
    homepage = "https://github.com/celiao/tmdbsimple";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ theobori ];
  };
})
