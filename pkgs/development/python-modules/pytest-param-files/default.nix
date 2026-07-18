{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  pytest,
  pytestCheckHook,
  ruamel-yaml,
}:

buildPythonPackage rec {
  pname = "pytest-param-files";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "chrisjsewell";
    repo = "pytest-param-files";
    tag = "v${version}";
    hash = "sha256-hgEEfKf9Kmah5WDNHoFWQJKLOs9Z5BDHiebXCdDc1zE=";
  };

  nativeBuildInputs = [ flit-core ];
  buildInputs = [ pytest ];
  propagatedBuildInputs = [ ruamel-yaml ];
  nativeCheckInputs = [ pytestCheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_param_files" ];

  meta = {
    description = "Package to generate parametrized pytests from external files";
    homepage = "https://github.com/chrisjsewell/pytest-param-files";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ loicreynier ];
  };
}
