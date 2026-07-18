{
  lib,
  buildPythonPackage,
  click,
  fetchPypi,
  prompt-toolkit,
  pygments,
  requests,
  setuptools,
  sqlparse,
}:

buildPythonPackage rec {
  pname = "clickhouse-cli";
  version = "0.3.9";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-gkgLAedUtzGv/4P+D56M2Pb5YecyqyVYp06ST62sjdY=";
  };

  nativeBuildInputs = [
    setuptools
  ];

  propagatedBuildInputs = [
    click
    prompt-toolkit
    pygments
    requests
    sqlparse
  ];

  pyproject = true;
  pythonImportsCheck = [ "clickhouse_cli" ];
  pythonRelaxDeps = [ "sqlparse" ];

  meta = {
    description = "Third-party client for the Clickhouse DBMS server";
    homepage = "https://github.com/hatarist/clickhouse-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ivan-babrou ];
    mainProgram = "clickhouse-cli";
  };
}
