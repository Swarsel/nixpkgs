{
  lib,
  stdenv,
  buildPythonPackage,
  cffi,
  fetchPypi,
  libngspice,
  matplotlib,
  numpy,
  ply,
  pyyaml,
  requests,
  scipy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pyspice";
  version = "1.5";

  src = fetchPypi {
    inherit version;
    sha256 = "d28448accad98959e0f5932af8736e90a1f3f9ff965121c6881d24cdfca23d22";
    pname = "PySpice";
  };

  postPatch = ''
    substituteInPlace PySpice/Spice/NgSpice/Shared.py --replace \
        "ffi.dlopen(self.library_path)" \
        "ffi.dlopen('${libngspice}/lib/libngspice${stdenv.hostPlatform.extensions.sharedLibrary}')"
  '';

  propagatedBuildInputs = [
    setuptools
    requests
    pyyaml
    cffi
    matplotlib
    numpy
    ply
    scipy
    libngspice
  ];

  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "PySpice" ];

  meta = {
    description = "Simulate electronic circuit using Python and the Ngspice / Xyce simulators";
    homepage = "https://github.com/FabriceSalvaire/PySpice";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ matthuszagh ];
  };
}
