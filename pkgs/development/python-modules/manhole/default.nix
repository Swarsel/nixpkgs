{
  lib,
  buildPythonPackage,
  fetchPypi,
  process-tests,
  pytest,
  requests,
}:

buildPythonPackage rec {
  pname = "manhole";
  version = "1.8.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-Nmj9r4OzPJQ9tOdQ4MVU4xwg9jM4SWiV3U1kEGgNnEs=";
  };

  # test_help expects architecture-dependent Linux signal numbers.
  #
  # {test_locals,test_socket_path} fail to remove /tmp/manhole-socket
  # on the x86_64-darwin builder.
  #
  # TODO: change this back to `doCheck = stdenv.hostPlatform.isLinux` after
  # https://github.com/ionelmc/python-manhole/issues/54 is fixed
  doCheck = false;

  nativeCheckInputs = [
    pytest
    requests
    process-tests
  ];

  checkPhase = ''
    # Based on its tox.ini
    export PYTHONUNBUFFERED=yes
    export PYTHONPATH=.:tests:$PYTHONPATH

    # The tests use manhole-cli
    export PATH="$PATH:$out/bin"

    # test_uwsgi fails with:
    # http.client.RemoteDisconnected: Remote end closed connection without response
    py.test -vv -k "not test_uwsgi"
  '';

  format = "setuptools";

  meta = {
    description = "Debugging manhole for Python applications";
    homepage = "https://github.com/ionelmc/python-manhole";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "manhole-cli";
  };
}
