{
  lib,
  stdenv,
  fetchFromGitHub,
  attrs,
  autobahn,
  buildPythonPackage,
  nixosTests,
  pytestCheckHook,
  setuptools,
  treq,
  twisted,
}:

buildPythonPackage (finalAttrs: {
  pname = "magic-wormhole-mailbox-server";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "magic-wormhole";
    repo = "magic-wormhole-mailbox-server";
    tag = finalAttrs.version;
    hash = "sha256-P1Pyz4uOoFeTc7Fd8DxeHW/Cig8i2QS3wh6vOSzaDKg=";
  };

  nativeCheckInputs = [
    pytestCheckHook
    treq
  ];

  build-system = [ setuptools ];

  dependencies = [
    attrs
    autobahn
    twisted
  ]
  ++ autobahn.optional-dependencies.twisted
  ++ twisted.optional-dependencies.tls;

  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [
    # these tests fail in Darwin's sandbox
    "src/wormhole_mailbox_server/test/test_web.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "wormhole_mailbox_server" ];

  passthru.tests = {
    inherit (nixosTests) magic-wormhole-mailbox-server;
  };

  meta = {
    description = "Securely transfer data between computers";
    homepage = "https://github.com/magic-wormhole/magic-wormhole-mailbox-server";
    changelog = "https://github.com/magic-wormhole/magic-wormhole-mailbox-server/blob/${finalAttrs.src.rev}/NEWS.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.mjoerg ];
  };
})
