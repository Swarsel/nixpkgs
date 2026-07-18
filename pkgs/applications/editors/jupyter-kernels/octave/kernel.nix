{
  lib,
  fetchPypi,
  python3Packages,
}:

with python3Packages;

buildPythonPackage (finalAttrs: {
  pname = "octave-kernel";
  version = "0.34.2";

  src = fetchPypi {
    inherit (finalAttrs) version;
    sha256 = "sha256-5ki2lekfK7frPsmPBIzYQOfANCUY9x+F2ZRAQSdPTxo=";
    pname = "octave_kernel";
  };

  propagatedBuildInputs = [
    metakernel
    ipykernel
  ];

  # Tests fail because the kernel appears to be halting or failing to launch
  # There appears to be a similar problem with metakernel's tests
  doCheck = false;
  format = "setuptools";

  meta = {
    description = "Jupyter kernel for Octave";
    homepage = "https://github.com/Calysto/octave_kernel";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ thomasjm ];
    platforms = lib.platforms.all;
  };
})
