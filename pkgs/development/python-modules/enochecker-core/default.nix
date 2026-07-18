{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "enochecker-core";
  version = "0.10.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-N41p2XRCp55rcPXLpA4rPIARsva/dQzK8qafjzXtavI=";
    pname = "enochecker_core";
  };

  # no tests upstream
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "enochecker_core" ];

  meta = {
    description = "Base library for enochecker libs";
    homepage = "https://github.com/enowars/enochecker_core";
    changelog = "https://github.com/enowars/enochecker_core/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fwc ];
  };
}
