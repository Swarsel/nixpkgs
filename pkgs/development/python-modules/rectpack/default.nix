{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "rectpack";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "secnot";
    repo = "rectpack";
    rev = version;
    hash = "sha256-kU0TT3wiudcLXrT+lYPYHYRtf7aNj/IKpnYKb/H91ng=";
  };

  # tests are base on nose
  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "rectpack" ];

  meta = {
    description = "Collection of algorithms for solving the 2D knapsack problem";
    homepage = "https://github.com/secnot/rectpack";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fbeffa ];
  };
}
