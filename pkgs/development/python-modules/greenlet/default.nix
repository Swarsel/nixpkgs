{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  # tests
  objgraph,
  psutil,
  python,
  # build-system
  setuptools,
  unittestCheckHook,
}:

let
  greenlet = buildPythonPackage rec {
    pname = "greenlet";
    version = "3.3.0";

    src = fetchPypi {
      inherit pname version;
      hash = "sha256-qCuyJaTp5NZT3S+3uLLTbk+yW8AWVCKhHki4jp5vePs=";
    };

    # https://github.com/python-greenlet/greenlet/issues/395
    env.NIX_CFLAGS_COMPILE = lib.optionalString (
      stdenv.hostPlatform.isPower64 || stdenv.hostPlatform.isLoongArch64
    ) "-fomit-frame-pointer";

    # tests in passthru, infinite recursion via objgraph/graphviz
    doCheck = false;

    nativeCheckInputs = [
      objgraph
      psutil
      unittestCheckHook
    ];

    preCheck = ''
      pushd ${placeholder "out"}/${python.sitePackages}
    '';

    postCheck = ''
      popd
    '';

    build-system = [ setuptools ];
    pyproject = true;
    unittestFlagsArray = [ "greenlet.tests" ];

    passthru.tests.pytest = greenlet.overridePythonAttrs (_: {
      doCheck = true;
    });

    meta = {
      description = "Module for lightweight in-process concurrent programming";
      homepage = "https://github.com/python-greenlet/greenlet";
      changelog = "https://github.com/python-greenlet/greenlet/blob/${version}/CHANGES.rst";

      license = with lib.licenses; [
        psfl # src/greenlet/slp_platformselect.h & files in src/greenlet/platform/ directory
        mit
      ];
    };
  };
in
greenlet
