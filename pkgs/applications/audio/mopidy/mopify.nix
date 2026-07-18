{
  lib,
  fetchPypi,
  mopidy,
  pythonPackages,
}:

pythonPackages.buildPythonApplication (finalAttrs: {
  pname = "mopidy-mopify";
  version = "1.7.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-RlCC+39zC+LeA/QDWPHYx5TrEwOgVrnvcH1Xg12qSLE=";
    pname = "Mopidy-Mopify";
  };

  # no tests implemented
  doCheck = false;

  build-system = [
    pythonPackages.setuptools
  ];

  dependencies = [
    mopidy
    pythonPackages.configobj
  ];

  pyproject = true;
  pythonImportsCheck = [ "mopidy_mopify" ];

  meta = {
    description = "Mopidy webclient based on the Spotify webbased interface";
    homepage = "https://github.com/dirkgroenen/mopidy-mopify";
    license = lib.licenses.gpl3;
    maintainers = [ ];
  };
})
