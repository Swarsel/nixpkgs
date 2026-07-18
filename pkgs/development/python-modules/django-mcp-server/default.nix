{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  django,
  djangorestframework,
  inflection,
  mcp,
  poetry-core,
  uritemplate,
}:

buildPythonPackage rec {
  pname = "django-mcp-server";
  version = "0.5.6";

  src = fetchFromGitHub {
    owner = "omarbenhamid";
    repo = "django-mcp-server";
    tag = "v${version}";
    hash = "sha256-HR4AzeDT/oWJe/exsV5AqwSebJPGT/vlzuk3qTgVb/M=";
  };

  doCheck = false; # Needs to run both test server and client simultaneously

  postFixup = ''
    export PYTHONPATH="$PWD/examples:$PYTHONPATH"
    export DJANGO_SETTINGS_MODULE=mcpexample.mcpexample.settings
  '';

  build-system = [ poetry-core ];

  dependencies = [
    django
    djangorestframework
    inflection
    mcp
    uritemplate
  ];

  pyproject = true;
  pythonImportsCheck = [ "mcp_server" ];

  meta = {
    description = "Django MCP Server implementation";
    homepage = "https://github.com/omarbenhamid/django-mcp-server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mrmebelman ];
  };
}
