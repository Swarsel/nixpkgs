{
  lib,
  stdenv,
  buildPythonPackage,
  cctools,
  fetchPypi,
  setuptools,
  which,
}:

buildPythonPackage rec {
  pname = "miniupnpc";
  version = "2.3.3";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-7l6Vffgo0vocw2TmDFg9EEOREIiPCGyRggcclqN0sq0=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    cctools
    which
  ];

  build-system = [
    setuptools
  ];

  pyproject = true;

  meta = {
    description = "MiniUPnP client";
    homepage = "http://miniupnp.free.fr/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ peterhoeg ];
  };
}
