{
  lib,
  buildPythonPackage,
  fetchPypi,
  fetchpatch,
  matplotlib,
  numpy,
  setuptools,
}:

buildPythonPackage rec {
  pname = "july";
  version = "0.1.3";

  # No tags on GitHub
  src = fetchPypi {
    inherit pname version;
    hash = "sha256-0xXCSSEKf2COJ9IHfuy+vpC/Zieg+q6TTabEFmUspCM=";
  };

  patches = [
    # Fixes compatibility with current matplotlib versions
    (fetchpatch {
      hash = "sha256-zgeUkDWCfAebt1rgDZgMUVgQF81NWGrG2tmSj4/ncYA=";
      url = "https://github.com/e-hulten/july/pull/44/commits/e5ff842bc98d3963c788737fff1b9086569b7d0a.patch";
    })
  ];

  # No tests
  doCheck = false;

  build-system = [
    setuptools
  ];

  dependencies = [
    matplotlib
    numpy
  ];

  pyproject = true;
  pythonImportsCheck = [ "july" ];

  meta = {
    description = "Small library for creating pretty heatmaps of daily data";
    homepage = "https://github.com/e-hulten/july";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
  };
}
