{
  lib,
  fetchFromGitHub,
  # scram
  argon2-cffi,
  # twisted
  attrs,
  # encryption
  base58,
  buildPythonPackage,
  # serialization
  cbor2,
  # build-system
  cffi,
  # dependencies
  cryptography,
  flatbuffers,
  hatchling,
  hyperlink,
  # tests
  mock,
  msgpack,
  passlib,
  py-ubjson,
  # ui
  pygobject3,
  pynacl,
  pyopenssl,
  pytest-asyncio_0,
  pytestCheckHook,
  # optional-dependencies
  # compress
  python-snappy,
  qrcode,
  service-identity,
  setuptools,
  twisted,
  txaio,
  ujson,
  zope-interface,
}:

buildPythonPackage (finalAttrs: {
  pname = "autobahn";
  version = "25.12.2";

  src = fetchFromGitHub {
    owner = "crossbario";
    repo = "autobahn-python";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vSS7DpfGfNwQT8OsgEXJaP5J40QFIopdAD94/y7/jFY=";
  };

  nativeCheckInputs = [
    mock
    pytest-asyncio_0
    pytestCheckHook
  ]
  ++ finalAttrs.passthru.optional-dependencies.encryption
  ++ finalAttrs.passthru.optional-dependencies.scram
  ++ finalAttrs.passthru.optional-dependencies.serialization;

  preCheck = ''
    # Run asyncio tests (requires twisted)
    export USE_ASYNCIO=1
    rm src/autobahn/__init__.py
  '';

  build-system = [
    cffi
    hatchling
    setuptools
  ];

  dependencies = [
    cryptography
    hyperlink
    pynacl
    txaio
  ];

  disabledTestPaths = [
    "src/autobahn/twisted"

    # Requires insecure ecdsa library
    "src/autobahn/wamp/test/test_wamp_cryptosign.py"
  ];

  enabledTestPaths = [
    "src/autobahn"
  ];

  optional-dependencies = lib.fix (self: {
    accelerate = [
      # wsaccel
    ];

    all =
      self.accelerate
      ++ self.compress
      ++ self.encryption
      ++ self.nvx
      ++ self.serialization
      ++ self.scram
      ++ self.twisted
      ++ self.ui;

    compress = [ python-snappy ];

    encryption = [
      base58
      # ecdsa (marked as insecure)
      pynacl
      pyopenssl
      qrcode # pytrie
      service-identity
    ];

    nvx = [ cffi ];

    scram = [
      argon2-cffi
      cffi
      passlib
    ];

    serialization = [
      cbor2
      flatbuffers
      msgpack
      ujson
      py-ubjson
    ];

    twisted = [
      attrs
      twisted
      zope-interface
    ];

    ui = [ pygobject3 ];
  });

  pyproject = true;
  pythonImportsCheck = [ "autobahn" ];

  meta = {
    description = "WebSocket and WAMP in Python for Twisted and asyncio";
    homepage = "https://crossbar.io/autobahn";
    changelog = "https://github.com/crossbario/autobahn-python/blob/${finalAttrs.src.tag}/docs/changelog.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
    downloadPage = "https://github.com/crossbario/autobahn-python";
  };
})
