{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  jinja2,
  kubernetes,
  pytest-bdd,
  pytest-cov-stub,
  pytestCheckHook,
  python-string-utils,
  ruamel-yaml,
  six,
}:

buildPythonPackage rec {
  pname = "openshift";
  version = "0.13.2";

  src = fetchFromGitHub {
    owner = "openshift";
    repo = "openshift-restclient-python";
    tag = "v${version}";
    hash = "sha256-uLfewj7M8KNs3oL1AM18sR/WhAR2mvBfqadyhR73FP0=";
  };

  propagatedBuildInputs = [
    jinja2
    kubernetes
    python-string-utils
    ruamel-yaml
    six
  ];

  nativeCheckInputs = [
    pytest-bdd
    pytest-cov-stub
    pytestCheckHook
  ];

  disabledTestPaths = [
    # requires kubeconfig
    "test/integration"
  ];

  format = "setuptools";
  pythonImportsCheck = [ "openshift" ];
  pythonRelaxDeps = [ "kubernetes" ];

  meta = {
    description = "Python client for the OpenShift API";
    homepage = "https://github.com/openshift/openshift-restclient-python";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ teto ];
  };
}
