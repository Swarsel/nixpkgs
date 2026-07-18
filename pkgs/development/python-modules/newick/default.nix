{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "newick";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "dlce-eva";
    repo = "python-newick";
    rev = "v${version}";
    hash = "sha256-TxyR6RYvy2oIcDNZnHrExtPYGspyWOtZqNy488OmWwk=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  pyproject = true;
  pythonImportsCheck = [ "newick" ];

  meta = {
    description = "Python package to read and write the Newick format";
    homepage = "https://github.com/dlce-eva/python-newick";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
