{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # dependencies
  pyyaml,
  requests,
  # build-system
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "scikit-hep-testdata";
  version = "0.6.7";

  src = fetchFromGitHub {
    owner = "scikit-hep";
    repo = "scikit-hep-testdata";
    tag = "v${version}";
    hash = "sha256-rBZWD3lzJwVQkibBLScfnYL3ChRsFDeDtheqqNjepEc=";
  };

  env.SKHEP_DATA = 1; # install the actual root files
  doCheck = false; # tests require networking
  build-system = [ setuptools-scm ];

  dependencies = [
    pyyaml
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "skhep_testdata" ];

  meta = {
    description = "Common package to provide example files (e.g., ROOT) for testing and developing packages against";
    homepage = "https://github.com/scikit-hep/scikit-hep-testdata";
    changelog = "https://github.com/scikit-hep/scikit-hep-testdata/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ veprbl ];
  };
}
