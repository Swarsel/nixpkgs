{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  isPy3k,
  mock,
  pytestCheckHook,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "stups-tokens";
  version = "1.1.19";

  src = fetchFromGitHub {
    owner = "zalando-stups";
    repo = "python-tokens";
    rev = version;
    sha256 = "09z3l3xzdlwpivbi141gk1k0zd9m75mjwbdy81zc386rr9k8s0im";
  };

  nativeCheckInputs = [
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];
  disabled = !isPy3k;
  pyproject = true;

  meta = {
    description = "Python library that keeps OAuth 2.0 service access tokens in memory for your usage";
    homepage = "https://github.com/zalando-stups/python-tokens";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.mschuwalow ];
  };
}
