{
  lib,
  # dependencies
  attrs,
  buildPythonPackage,
  fetchPypi,
  hatchling,
  # tests
  httpbin,
  hyperlink,
  # build-system
  incremental,
  multipart,
  requests,
  twisted,
}:

buildPythonPackage (finalAttrs: {
  pname = "treq";
  version = "25.5.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-Jd3jpVroXsLyxWMyyZrvJVqxT5l9DQBVLr/xNTipgEo=";
  };

  nativeBuildInputs = [
    incremental
    hatchling
  ];

  propagatedBuildInputs = [
    attrs
    hyperlink
    incremental
    multipart
    requests
    twisted
  ]
  ++ twisted.optional-dependencies.tls;

  nativeCheckInputs = [
    httpbin
    twisted
  ];

  checkPhase = ''
    runHook preCheck

    trial treq

    runHook postCheck
  '';

  pyproject = true;

  meta = {
    description = "Requests-like API built on top of twisted.web's Agent";
    homepage = "https://github.com/twisted/treq";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
