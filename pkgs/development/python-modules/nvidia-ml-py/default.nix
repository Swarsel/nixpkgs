{
  lib,
  addDriverRunpath,
  buildPythonPackage,
  cudaPackages,
  fetchPypi,
  nvidia-ml-py,
  replaceVars,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "nvidia-ml-py";
  version = "13.610.43";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-ZUN+tz1o0MYskxyk1FA4Ry+v8DvQuHKau6S4mfcNYPI=";
    pname = "nvidia_ml_py";
  };

  patches = [
    (replaceVars ./0001-locate-libnvidia-ml.so.1-on-NixOS.patch {
      inherit (addDriverRunpath) driverLink;
    })
  ];

  # no tests
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  pyproject = true;
  pythonImportsCheck = [ "pynvml" ];

  passthru.tests.tester-nvmlInit =
    cudaPackages.writeGpuTestPython { libraries = [ nvidia-ml-py ]; }
      ''
        from pynvml import (
          nvmlInit,
          nvmlSystemGetDriverVersion,
          nvmlDeviceGetCount,
          nvmlDeviceGetHandleByIndex,
          nvmlDeviceGetName,
        )

        nvmlInit()
        print(f"Driver Version: {nvmlSystemGetDriverVersion()}")

        for i in range(nvmlDeviceGetCount()):
            handle = nvmlDeviceGetHandleByIndex(i)
            print(f"Device {i} : {nvmlDeviceGetName(handle)}")
      '';

  meta = {
    description = "Python Bindings for the NVIDIA Management Library";
    homepage = "https://pypi.org/project/nvidia-ml-py";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ GaetanLepage ];
  };
})
