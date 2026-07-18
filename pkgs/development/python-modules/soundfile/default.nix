{
  lib,
  stdenv,
  buildPythonPackage,
  cffi,
  fetchPypi,
  isPyPy,
  libsndfile,
  numpy,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "soundfile";
  version = "0.13.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ssaNqx4wKXMXCApbQ99X4wJYTEnilC3v3eCszMU/Dls=";
  };

  postPatch = ''
    substituteInPlace soundfile.py --replace "_find_library('sndfile')" "'${libsndfile.out}/lib/libsndfile${stdenv.hostPlatform.extensions.sharedLibrary}'"
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  build-system = [
    setuptools
    cffi
  ];

  dependencies = [
    numpy
    cffi
  ];

  disabled = isPyPy;
  pyproject = true;
  pythonImportsCheck = [ "soundfile" ];

  meta = {
    description = "Audio library based on libsndfile, CFFI and NumPy";
    homepage = "https://github.com/bastibe/python-soundfile";
    license = lib.licenses.bsd3;
    # https://github.com/bastibe/python-soundfile/issues/157
    broken = stdenv.hostPlatform.isi686;
  };
}
