{
  lib,
  stdenv,
  fetchFromGitHub,
  bottle,
  buildPythonPackage,
  curl,
  fetchpatch2,
  flaky,
  flask,
  isPyPy,
  numpy,
  openssl,
  pytestCheckHook,
  setuptools,
  websockets,
}:

buildPythonPackage rec {
  pname = "pycurl";
  version = "7.46.0";

  src = fetchFromGitHub {
    owner = "pycurl";
    repo = "pycurl";
    tag = "REL_${lib.replaceStrings [ "." ] [ "_" ] version}";
    hash = "sha256-F40bJ7TYFK2dVkDJGGxl7XV46fKmjwvUYYulcwGL6hk=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-EBXgGiaMtXTsgJOOrzzZFJ7Q/ofAlc4zuipoEpfdFqU=";
      name = "pycurl-curl-8.21.0-ws-support.patch";
      url = "https://github.com/pycurl/pycurl/commit/c78fd8aba82e2f8037275063138eaa7706c111af.diff?full_index=1";
    })
  ];

  nativeBuildInputs = [ curl ];

  buildInputs = [
    curl
    openssl
  ];

  preConfigure = ''
    substituteInPlace setup.py \
      --replace-fail '--static-libs' '--libs'
    export PYCURL_SSL_LIBRARY=openssl
  '';

  nativeCheckInputs = [
    bottle
    flaky
    flask
    numpy
    websockets
    pytestCheckHook
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  disabled = isPyPy; # https://github.com/pycurl/pycurl/issues/208

  disabledTests = [
    # tests that require network access
    "test_keyfunction"
    "test_keyfunction_bogus_return"
    # OSError: tests/fake-curl/libcurl/with_openssl.so: cannot open shared object file: No such file or directory
    "test_libcurl_ssl_openssl"
    # OSError: tests/fake-curl/libcurl/with_nss.so: cannot open shared object file: No such file or directory
    "test_libcurl_ssl_nss"
    # OSError: tests/fake-curl/libcurl/with_gnutls.so: cannot open shared object file: No such file or directory
    "test_libcurl_ssl_gnutls"
    # AssertionError: assert 'crypto' in ['curl']
    "test_ssl_in_static_libs"
    # expected socketp to be None again after unassign()
    "test_clear_via_assign_none_inside_callback_resets_socketp"
    "test_multi_unassign_inside_socket_callback"
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    # Fatal Python error: Segmentation fault
    "cadata_test"
  ];

  enabledTestPaths = [
    # don't pick up the tests directory below examples/
    "tests"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pycurl" ];

  meta = {
    description = "Python Interface To The cURL library";
    homepage = "http://pycurl.io/";

    changelog =
      "https://github.com/pycurl/pycurl/blob/REL_"
      + lib.replaceStrings [ "." ] [ "_" ] version
      + "/ChangeLog";

    license = with lib.licenses; [
      lgpl2Only
      mit
    ];

    maintainers = [ ];
  };
}
