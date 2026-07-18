{
  lib,
  stdenv,
  fetchFromGitHub,
  aiohttp,
  buildPythonPackage,
  eventlet,
  iana-etc,
  libredirect,
  mock,
  pytest-asyncio,
  pytestCheckHook,
  requests,
  setuptools,
  simple-websocket,
  tornado,
  websocket-client,
}:

buildPythonPackage rec {
  pname = "python-engineio";
  version = "4.13.3";

  src = fetchFromGitHub {
    owner = "miguelgrinberg";
    repo = "python-engineio";
    tag = "v${version}";
    hash = "sha256-3KWhQE4STzwEtFzuhiTQZcc9a3lWoQlW74oHtbR4N6M=";
  };

  nativeCheckInputs = [
    eventlet
    libredirect.hook
    mock
    tornado
    pytest-asyncio
    pytestCheckHook
  ]
  ++ lib.concatAttrValues optional-dependencies;

  preCheck = lib.optionalString stdenv.hostPlatform.isLinux ''
    echo "nameserver 127.0.0.1" > resolv.conf
    export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols:/etc/resolv.conf=$(realpath resolv.conf)
  '';

  postCheck = ''
    unset NIX_REDIRECTS LD_PRELOAD
  '';

  build-system = [ setuptools ];
  dependencies = [ simple-websocket ];

  disabledTests = [
    # Assertion issue
    "test_async_mode_eventlet"
    # Somehow effective log level does not change?
    "test_logger"
  ];

  optional-dependencies = {
    asyncio_client = [ aiohttp ];

    client = [
      requests
      websocket-client
    ];
  };

  pyproject = true;
  pythonImportsCheck = [ "engineio" ];

  meta = {
    description = "Python based Engine.IO client and server";

    longDescription = ''
      Engine.IO is a lightweight transport protocol that enables real-time
      bidirectional event-based communication between clients and a server.
    '';

    homepage = "https://github.com/miguelgrinberg/python-engineio/";
    changelog = "https://github.com/miguelgrinberg/python-engineio/blob/${src.tag}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mic92 ];
  };
}
