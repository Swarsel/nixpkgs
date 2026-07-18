{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  numpy,
  python,
  scikit-learn,
  scipy,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "quantile-forest";
  version = "1.4.2";

  src = fetchFromGitHub {
    owner = "zillow";
    repo = "quantile-forest";
    tag = "v${version}";
    hash = "sha256-K/8W/BkQVeFsJyQMdOHX997/yrhTcvHU9vuYmZ4W+Qo=";
  };

  # need network connection
  doCheck = false;

  postInstall = ''
    rm -rf $out/${python.sitePackages}/examples
  '';

  build-system = [
    setuptools
    cython
    wheel
    numpy
    scipy
    scikit-learn
  ];

  dependencies = [
    numpy
    scipy
    scikit-learn
  ];

  pyproject = true;
  pythonImportsCheck = [ "quantile_forest" ];

  meta = {
    description = "Quantile Regression Forests compatible with scikit-learn";
    homepage = "https://github.com/zillow/quantile-forest";
    changelog = "https://github.com/zillow/quantile-forest/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ vizid ];
  };
}
