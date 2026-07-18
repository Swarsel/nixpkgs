{
  lib,
  buildPythonPackage,
  fetchPypi,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "braceexpand";
  version = "0.1.7";

  src = fetchPypi {
    inherit version pname;
    sha256 = "01gpcnksnqv6np28i4x8s3wkngawzgs99zvjfia57spa42ykkrg6";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "braceexpand" ];

  meta = {
    description = "Bash-style brace expansion for Python";
    homepage = "https://github.com/trendels/braceexpand";
    changelog = "https://github.com/trendels/braceexpand/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      newam
      pbsds
    ];
  };
}
