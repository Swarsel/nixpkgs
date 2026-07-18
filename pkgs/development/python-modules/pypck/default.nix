{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-asyncio,
  pytest-timeout,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pypck";
  version = "0.9.13";

  src = fetchFromGitHub {
    owner = "alengwenus";
    repo = "pypck";
    tag = finalAttrs.version;
    hash = "sha256-b8uTY4UtyhKN7JDvu/wC1jXAN/oKs2cJ6sSRBC22vS0=";
  };

  postPatch = ''
    echo "${finalAttrs.version}" > VERSION
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytest-timeout
    pytestCheckHook
  ];

  __darwinAllowLocalNetworking = true;
  build-system = [ setuptools ];
  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [ "test_connection_lost" ];
  pyproject = true;
  pythonImportsCheck = [ "pypck" ];

  meta = {
    description = "LCN-PCK library written in Python";
    homepage = "https://github.com/alengwenus/pypck";
    changelog = "https://github.com/alengwenus/pypck/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.epl20;
    maintainers = with lib.maintainers; [ fab ];
  };
})
