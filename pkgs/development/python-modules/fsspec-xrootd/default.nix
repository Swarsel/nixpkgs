{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  fsspec,
  # tests
  pkgs,
  pytestCheckHook,
  # build-system
  setuptools,
  setuptools-scm,
  xrootd,
}:

buildPythonPackage (finalAttrs: {
  pname = "fsspec-xrootd";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "CoffeaTeam";
    repo = "fsspec-xrootd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dlSh2TH7SQ95kFNPlSjMa697WdBURRlBxNtNf04uaBU=";
  };

  nativeCheckInputs = [
    pkgs.xrootd
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    fsspec
    xrootd
  ];

  # Timeout related tests hang indifinetely
  disabledTestPaths = lib.optionals stdenv.hostPlatform.isDarwin [ "tests/test_basicio.py" ];

  disabledTests = [
    # Hangs indefinitely
    "test_broken_server"

    # Fails (on aarch64-linux) as it runs sleep, touch, stat and makes assumptions about the
    # scheduler and the filesystem.
    "test_touch_modified"
  ];

  pyproject = true;
  pythonImportsCheck = [ "fsspec_xrootd" ];

  meta = {
    description = "XRootD implementation for fsspec";
    homepage = "https://github.com/CoffeaTeam/fsspec-xrootd";
    changelog = "https://github.com/CoffeaTeam/fsspec-xrootd/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
