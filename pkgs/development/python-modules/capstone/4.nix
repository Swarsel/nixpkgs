{
  lib,
  stdenv,
  buildPythonPackage,
  capstone_4,
  fetchpatch,
  setuptools,
}:

buildPythonPackage {
  inherit (capstone_4) version src;
  pname = "capstone";

  patches = [
    # Drop distutils in python binding (PR 2271)
    (fetchpatch {
      hash = "sha256-zUGeFmm3xH5dzfPJE8nnHwqwFBrsZ7w8LBJAy20/3RI=";
      name = "drop-distutils-in-python-binding.patch";
      stripLen = 2;
      url = "https://github.com/capstone-engine/capstone/commit/d63211e3acb64fceb8b1c4a0d804b4b027f4ef71.patch";
    })
  ];

  postPatch = ''
    ln -s ${capstone_4}/lib/libcapstone${stdenv.targetPlatform.extensions.sharedLibrary} prebuilt/
    ln -s ${capstone_4}/lib/libcapstone${stdenv.targetPlatform.extensions.staticLibrary} prebuilt/
    substituteInPlace setup.py --replace manylinux1 manylinux2014
  '';

  propagatedBuildInputs = [ setuptools ];

  checkPhase = ''
    mv capstone capstone.hidden
    patchShebangs test_*
    make check
  '';

  format = "setuptools";

  # aarch64 only available from MacOS SDK 11 onwards, so fix the version tag.
  # otherwise, bdist_wheel may detect "macosx_10_6_arm64" which doesn't make sense.
  setupPyBuildFlags = lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    "--plat-name"
    "macosx_11_0"
  ];

  sourceRoot = "${capstone_4.src.name}/bindings/python";

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
