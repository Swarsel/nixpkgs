{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  lsprotocol,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  typeguard,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "pygls";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "openlawlibrary";
    repo = "pygls";
    tag = "v${finalAttrs.version}";
    hash = "sha256-AvrGoQ0Be1xKZhFn9XXYJpt5w+ITbDbj6NFZpaDPKao=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    lsprotocol
    typeguard
  ];

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  preCheck = lib.optionalString stdenv.hostPlatform.isDarwin ''
    # Darwin issue: OSError: [Errno 24] Too many open files
    ulimit -n 1024
  '';

  # Fixes hanging tests on Darwin
  __darwinAllowLocalNetworking = true;

  optional-dependencies = {
    ws = [ websockets ];
  };

  pyproject = true;
  pythonImportsCheck = [ "pygls" ];

  pythonRelaxDeps = [
    # https://github.com/openlawlibrary/pygls/pull/432
    "lsprotocol"
  ];

  passthru.skipBulkUpdate = true;

  meta = {
    description = "Pythonic generic implementation of the Language Server Protocol";
    homepage = "https://github.com/openlawlibrary/pygls";
    changelog = "https://github.com/openlawlibrary/pygls/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kira-bruneau ];
    broken = lib.versionAtLeast lsprotocol.version "2024";
  };
})
