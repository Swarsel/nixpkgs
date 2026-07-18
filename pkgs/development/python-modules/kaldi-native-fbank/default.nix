{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  kissfft,
  pybind11,
  setuptools,
}:
buildPythonPackage (finalAttrs: {
  pname = "kaldi-native-fbank";
  version = "1.22.3";

  src = fetchFromGitHub {
    owner = "csukuangfj";
    repo = "kaldi-native-fbank";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Wu4wM52T6NoQ1t5/iAyPtkEGnZki5P0jx0eYMFZMb5o=";
  };

  buildInputs = [ pybind11 ];

  env.KALDI_NATIVE_FBANK_CMAKE_ARGS = lib.concatStringsSep " " [
    "-DFETCHCONTENT_SOURCE_DIR_KISSFFT=${kissfft.src}"
    "-DFETCHCONTENT_SOURCE_DIR_PYBIND11=${pybind11.src}"
    "-DKALDI_NATIVE_FBANK_BUILD_TESTS=OFF"
    "-DKALDI_NATIVE_FBANK_BUILD_PYTHON=ON"
  ];

  build-system = [
    cmake
    setuptools
  ];

  dontUseCmakeConfigure = true;
  pyproject = true;
  pythonImportsCheck = [ "kaldi_native_fbank" ];

  meta = {
    description = "Kaldi-compatible online fbank extractor without external dependencies";
    homepage = "https://github.com/csukuangfj/kaldi-native-fbank";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lach ];
  };
})
