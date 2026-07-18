{
  lib,
  stdenv,
  buildPythonPackage,
  capstone,
  setuptools,
}:

buildPythonPackage rec {
  pname = "capstone";
  version = lib.getVersion capstone;
  src = capstone.src;

  # libcapstone.a is not built with BUILD_SHARED_LIBS. For some reason setup.py
  # checks if it exists but it is not really needed. Most likely a bug in setup.py.
  postPatch = ''
    ln -s ${capstone}/lib/libcapstone${stdenv.targetPlatform.extensions.sharedLibrary} prebuilt/
    touch prebuilt/libcapstone${stdenv.targetPlatform.extensions.staticLibrary}
    substituteInPlace setup.py --replace manylinux1 manylinux2014
  '';

  propagatedBuildInputs = [ setuptools ];

  checkPhase = ''
    mv capstone capstone.hidden
    pushd tests
      patchShebangs test_*
      make -f ../Makefile check
    popd
  '';

  format = "setuptools";

  # aarch64 only available from MacOS SDK 11 onwards, so fix the version tag.
  # otherwise, bdist_wheel may detect "macosx_10_6_arm64" which doesn't make sense.
  setupPyBuildFlags = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    "--plat-name"
    "macosx_11_0"
  ];

  sourceRoot = "${src.name}/bindings/python";

  meta = {
    description = "Python bindings for Capstone disassembly engine";
    homepage = "http://www.capstone-engine.org/";
    license = lib.licenses.bsdOriginal;

    maintainers = with lib.maintainers; [
      bennofs
      ris
    ];
  };
}
