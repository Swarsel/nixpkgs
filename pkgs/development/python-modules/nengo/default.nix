{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  numpy,
  scikit-learn,
  scipy,
  setuptools,
  scikitSupport ? false,
  scipySupport ? false,
}:

buildPythonPackage (finalAttrs: {
  pname = "nengo";
  version = "4.1.0";

  src = fetchFromGitHub {
    owner = "nengo";
    repo = "nengo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yZDnttXU5qMmQwFESkhQb06BXcqPEiPYl54azS5b284=";
  };

  # checks req missing:
  #   pytest-allclose
  #   pytest-plt
  #   pytest-rng
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    numpy
  ]
  ++ lib.optionals scipySupport [ scipy ]
  ++ lib.optionals scikitSupport [ scikit-learn ];

  pyproject = true;
  pythonImportsCheck = [ "nengo" ];

  meta = {
    description = "Python library for creating and simulating large-scale brain models";
    homepage = "https://nengo.ai/";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
  };
})
