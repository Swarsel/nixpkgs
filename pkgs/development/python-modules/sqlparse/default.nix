{
  lib,
  buildPythonPackage,
  # for passthru.tests
  django,
  django-silk,
  fetchPypi,
  hatchling,
  installShellFiles,
  pgadmin4,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "sqlparse";
  version = "0.5.5";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-4g1KmwuFhf32OxDTAGbHyUxden7EfIiaLYOjyqk/8o4=";
  };

  nativeBuildInputs = [ installShellFiles ];
  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = ''
    installManPage docs/sqlformat.1
  '';

  build-system = [ hatchling ];
  pyproject = true;

  passthru.tests = {
    inherit
      django
      django-silk
      pgadmin4
      ;
  };

  meta = {
    description = "Non-validating SQL parser for Python";

    longDescription = ''
      Provides support for parsing, splitting and formatting SQL statements.
    '';

    homepage = "https://github.com/andialbrecht/sqlparse";
    changelog = "https://github.com/andialbrecht/sqlparse/blob/${version}/CHANGELOG";
    license = lib.licenses.bsd3;
    mainProgram = "sqlformat";
  };
}
