{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  fluidsynth,
  numpy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyfluidsynth";
  version = "1.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-ap4duvRp/RH0UYTzfsKOGYsdZJWtdPYdxKV3JrKxujE=";
  };

  postPatch = ''
    substituteInPlace fluidsynth.py \
      --replace-fail \
        "find_library(lib_name)" \
        '"${lib.getLib fluidsynth}/lib/libfluidsynth${stdenv.hostPlatform.extensions.sharedLibrary}"'
  '';

  build-system = [ setuptools ];
  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "fluidsynth" ];

  meta = {
    description = "Python bindings for FluidSynth, a MIDI synthesizer that uses SoundFont instruments";
    homepage = "https://github.com/nwhitehead/pyfluidsynth";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ ];
  };
}
