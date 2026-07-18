{
  lib,
  stdenv,
  buildPythonPackage,
  capstone,
  pytestCheckHook,
  setuptools,
  setuptools-scm,
  unicorn,
}:

buildPythonPackage rec {
  pname = "unicorn";
  version = lib.getVersion unicorn;
  src = unicorn.src;

  nativeCheckInputs = [
    capstone
    pytestCheckHook
  ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  # this test does not appear to be intended as a pytest-style test
  disabledTests = [ "test_i386" ];

  prePatch = ''
    ln -s ${unicorn}/lib/libunicorn.* prebuilt/
  '';

  pyproject = true;
  pythonImportsCheck = [ "unicorn" ];

  # Needed on non-x86 linux
  setupPyBuildFlags =
    lib.optionals stdenv.hostPlatform.isLinux [
      "--plat-name"
      "linux"
    ]
    # aarch64 only available from MacOS SDK 11 onwards, so fix the version tag.
    # otherwise, bdist_wheel may detect "macosx_10_6_arm64" which doesn't make sense.
    ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
      "--plat-name"
      "macosx_11_0"
    ];

  sourceRoot = "${src.name}/bindings/python";

  meta = {
    description = "Python bindings for Unicorn CPU emulator engine";
    homepage = "https://www.unicorn-engine.org/";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      bennofs
      ris
    ];
  };
}
