{
  lib,
  buildPythonPackage,
  bzip2,
  fetchPypi,
  openssl,
  pythonAtLeast,
  setuptools,
}:

buildPythonPackage rec {
  pname = "zeroc-ice";
  version = "3.8.0.post1";

  src = fetchPypi {
    inherit version;
    hash = "sha256-SwR/4BSH/8+cYWVKA7aE3bnFOL52fWzynFehZr5VC9c=";
    pname = "zeroc_ice";
  };

  buildInputs = [
    bzip2
    openssl
  ];

  build-system = [ setuptools ];
  # Upstream PR: https://github.com/zeroc-ice/ice/pull/2910
  # But this hasn't been merged into the 3.7 branch, and the patch doesn't
  # apply cleanly.
  disabled = pythonAtLeast "3.13";
  pyproject = true;
  pythonImportsCheck = [ "Ice" ];

  meta = {
    description = "Comprehensive RPC framework with support for Python, C++, .NET, Java, JavaScript and more";
    homepage = "https://zeroc.com/";
    license = lib.licenses.gpl2;
    maintainers = [ ];
    mainProgram = "slice2py";
  };
}
