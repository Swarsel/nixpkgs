{
  lib,
  stdenv,
  fetchFromGitHub,
  attrs,
  buildPythonPackage,
  cattrs,
  lsprotocol,
  nix-update-script,
  poetry-core,
  pytest-asyncio,
  pytestCheckHook,
  websockets,
}:

buildPythonPackage (finalAttrs: {
  pname = "pygls";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "openlawlibrary";
    repo = "pygls";
    tag = "v${finalAttrs.version}";
    hash = "sha256-jxc1nKxfiRenb629a2WCZOzqyIOvT5XU4NrjmKPlDHk=";
  };

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    attrs
    cattrs
    lsprotocol
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      # Skips pre-releases
      "--version-regex"
      "^v([0-9.]+)$"
    ];
  };

  meta = {
    description = "Pythonic generic implementation of the Language Server Protocol";
    homepage = "https://github.com/openlawlibrary/pygls";
    changelog = "https://github.com/openlawlibrary/pygls/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kira-bruneau ];
  };
})
