{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  httpcore,
  httpx,
  kubo,
  mock,
  py-multiaddr,
  pytest-cid,
  pytest-cov-stub,
  pytest-dependency,
  pytest-localserver,
  pytest-mock,
  pytest-order,
  pytestCheckHook,
  python,
  requests,
}:

buildPythonPackage rec {
  pname = "ipfshttpclient";
  version = "0.8.0a2";

  src = fetchFromGitHub {
    owner = "ipfs-shipyard";
    repo = "py-ipfs-http-client";
    rev = version;
    hash = "sha256-OmC67pN2BbuGwM43xNDKlsLhwVeUbpvfOazyIDvoMEA=";
  };

  postPatch = ''
    # This can be removed for the 0.8.0 release
    # Use pytest-order instead of pytest-ordering since the latter is unmaintained and broken
    substituteInPlace test/run-tests.py \
      --replace 'pytest_ordering' 'pytest_order'
    substituteInPlace test/functional/test_miscellaneous.py \
      --replace '@pytest.mark.last' '@pytest.mark.order("last")'

    # Until a proper fix is created, just skip these tests
    # and ignore any breakage that may result from the API change in IPFS
    # See https://github.com/ipfs-shipyard/py-ipfs-http-client/issues/308
    substituteInPlace test/functional/test_pubsub.py \
      --replace '# the message that will be published' 'pytest.skip("This test fails because of an incompatibility with the experimental PubSub feature in IPFS>=0.11.0")' \
      --replace '# subscribe to the topic testing'     'pytest.skip("This test fails because of an incompatibility with the experimental PubSub feature in IPFS>=0.11.0")'
    substituteInPlace test/functional/test_other.py \
      --replace 'import ipfshttpclient' 'import ipfshttpclient; import pytest' \
      --replace 'assert ipfs_is_available' 'pytest.skip("Unknown test failure with IPFS >=0.11.0"); assert ipfs_is_available'
  '';

  nativeBuildInputs = [ flit-core ];

  propagatedBuildInputs = [
    py-multiaddr
    requests
  ];

  doCheck = false;

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
    pytest-dependency
    pytest-localserver
    pytest-mock
    pytest-order
    pytest-cid
    mock
    kubo
    httpcore
    httpx
  ];

  checkPhase = ''
    runHook preCheck

    ${python.interpreter} -X utf8 test/run-tests.py

    runHook postCheck
  '';

  pyproject = true;
  pythonImportsCheck = [ "ipfshttpclient" ];

  meta = {
    description = "Python client library for the IPFS API";
    homepage = "https://github.com/ipfs-shipyard/py-ipfs-http-client";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      mguentner
      Luflosi
    ];
  };
}
