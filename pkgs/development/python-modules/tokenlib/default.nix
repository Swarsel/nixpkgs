{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  requests,
  setuptools,
  webob,
}:

buildPythonPackage rec {
  pname = "tokenlib";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "mozilla-services";
    repo = "tokenlib";
    rev = "${version}";
    hash = "sha256-+KybaLb4XAcuBARJUhL5gK71jfNMb8YL8dV5Vzf7yXI=";
  };

  patches = [
    # fix wrong function name in tests
    # See https://github.com/mozilla-services/tokenlib/pull/9
    (fetchpatch {
      hash = "sha256-hc+iydxZu9bFqBD0EQDWMkRs2ibqNAhx6Qxjh6ppKNw=";
      url = "https://github.com/mozilla-services/tokenlib/pull/9/commits/cb7ef761f82f36e40069bd1b8684eec05af3b8a3.patch";
    })
  ];

  build-system = [ setuptools ];

  dependencies = [
    requests
    webob
  ];

  pyproject = true;
  pythonImportsCheck = [ "tokenlib" ];

  meta = {
    description = "Generic support library for signed-token-based auth schemes";
    homepage = "https://github.com/mozilla-services/tokenlib";
    license = lib.licenses.mpl20;
  };
}
