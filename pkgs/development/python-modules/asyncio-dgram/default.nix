{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  hatchling,
  pytest-asyncio,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "asyncio-dgram";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "jsbronder";
    repo = "asyncio-dgram";
    tag = "v${finalAttrs.version}";
    hash = "sha256-08XQHx+ArduVdkK5ZYq2lL2OWF9CvdSWcNLfc7ey2wI=";
  };

  # OSError: AF_UNIX path too long
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ hatchling ];

  disabledTests = [
    "test_protocol_pause_resume"
    # TypeError: socket type must be 2
    "test_from_socket_bad_socket"
  ];

  pyproject = true;
  pythonImportsCheck = [ "asyncio_dgram" ];

  meta = {
    description = "Python support for higher level Datagram";
    homepage = "https://github.com/jsbronder/asyncio-dgram";
    changelog = "https://github.com/jsbronder/asyncio-dgram/blob/${finalAttrs.src.tag}/ChangeLog";
    license = with lib.licenses; [ mit ];
    maintainers = with lib.maintainers; [ fab ];
  };
})
