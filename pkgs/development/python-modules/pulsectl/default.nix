{
  lib,
  stdenv,
  buildPythonPackage,
  fetchPypi,
  glibc,
  libpulseaudio,
  pulseaudio,
  replaceVars,
  setuptools,
  unittestCheckHook,
  writableTmpDirAsHomeHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pulsectl";
  version = "24.12.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-KI1nFSMqxvPc2xI/vsqiwLmlDqQIfm6Hw/hBqwqKB/w=";
  };

  patches = [
    # substitute library paths for libpulse and librt
    (replaceVars ./library-paths.patch {
      libpulse = "${libpulseaudio.out}/lib/libpulse${stdenv.hostPlatform.extensions.sharedLibrary}";
      librt = "${glibc.out}/lib/librt${stdenv.hostPlatform.extensions.sharedLibrary}";
    })
  ];

  nativeCheckInputs = [
    writableTmpDirAsHomeHook
    unittestCheckHook
    pulseaudio
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pulsectl" ];

  meta = {
    description = "Python high-level interface and ctypes-based bindings for PulseAudio (libpulse)";
    homepage = "https://github.com/mk-fg/python-pulse-control";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ hexa ];
  };
})
