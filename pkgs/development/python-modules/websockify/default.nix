{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  jwcrypto,
  numpy,
  pytestCheckHook,
  redis,
  requests,
  setuptools,
  simplejson,
}:

buildPythonPackage (finalAttrs: {
  pname = "websockify";
  version = "0.13.0";

  src = fetchFromGitHub {
    owner = "novnc";
    repo = "websockify";
    tag = "v${finalAttrs.version}";
    hash = "sha256-b57L4o071zEt/gX9ZVzEpcnp0RCeo3peZrby2mccJgQ=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    jwcrypto
    numpy
    redis
    requests
    simplejson
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # this test failed on macos
    # https://github.com/novnc/websockify/issues/552
    "test_socket_set_keepalive_options"
  ];

  pyproject = true;
  pythonImportsCheck = [ "websockify" ];

  meta = {
    description = "WebSockets support for any application/server";
    homepage = "https://github.com/novnc/websockify";
    changelog = "https://github.com/novnc/websockify/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Only;
    maintainers = [ ];
    mainProgram = "websockify";
  };
})
