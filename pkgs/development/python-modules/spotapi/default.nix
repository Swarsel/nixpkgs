{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  colorama,
  fetchPypi,
  pillow,
  pymongo,
  pyotp,
  readerwriterlock,
  redis,
  requests,
  setuptools,
  tls-client,
  typing-extensions,
  validators,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "spotapi";
  version = "1.2.7";

  # no tags on GitHub
  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-x4UA65A4UvxqlDN5upHsPPa5yv8gKZw3kqLou/1xVtY=";
  };

  # upstream has no unit tests
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    beautifulsoup4
    colorama
    pillow
    pyotp
    readerwriterlock
    requests
    tls-client
    typing-extensions
    validators
  ]
  # optional dependencies are always imported
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  optional-dependencies = {
    pymongo = [ pymongo ];
    redis = [ redis ];
    websocket = [ websockets ];
  };

  pyproject = true;
  pythonImportsCheck = [ "spotapi" ];

  meta = {
    description = "Python wrapper for the public & private Spotify API";
    homepage = "https://github.com/Aran404/SpotAPI";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.dotlambda ];
  };
})
