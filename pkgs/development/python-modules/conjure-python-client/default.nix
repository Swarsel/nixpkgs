{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  pyyaml,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "conjure-python-client";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "palantir";
    repo = "conjure-python-client";
    tag = version;
    hash = "sha256-z6+790fFpI7uYI6O4MXnCOZc/o96r2f8ttj+IsXStYI=";
  };

  # https://github.com/palantir/conjure-python-client/blob/3.0.0/setup.py#L57
  postPatch = ''
    echo '__version__ = "${version}"' > ./conjure_python_client/_version.py
  '';

  nativeCheckInputs = [
    pytestCheckHook
    pyyaml
  ];

  build-system = [ setuptools ];
  dependencies = [ requests ];

  # some tests depend on a code generator that isn't available in nixpkgs
  # https://github.com/palantir/conjure-python-client/blob/3.0.0/CONTRIBUTING.md?plain=1#L23
  disabledTestPaths = [
    "test/conjure/test_conjure_repr.py"
    "test/integration_test"
    "test/serde/test_decode_union.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "conjure_python_client" ];

  meta = {
    description = "Python client and JSON encoders for use with generated Conjure clients";
    homepage = "https://github.com/palantir/conjure-python-client";
    changelog = "https://github.com/palantir/conjure-python-client/releases/tag/${version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ alkasm ];
  };
}
