{
  lib,
  argcomplete,
  buildPythonPackage,
  fetchPypi,
  gql,
  pyyaml,
  requests,
  requests-toolbelt,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-gitlab";
  version = "8.4.0";

  src = fetchPypi {
    inherit version;
    hash = "sha256-828g7D8JE487EgiTlJQfTb5aQHAhvtcbcKBLvdN7inQ=";
    pname = "python_gitlab";
  };

  # Tests rely on a gitlab instance on a local docker setup
  doCheck = false;
  build-system = [ setuptools ];

  dependencies = [
    requests
    requests-toolbelt
  ];

  optional-dependencies = {
    autocompletion = [ argcomplete ];
    graphql = [ gql ] ++ gql.optional-dependencies.httpx;
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "gitlab" ];

  meta = {
    description = "Interact with GitLab API";
    homepage = "https://github.com/python-gitlab/python-gitlab";
    changelog = "https://github.com/python-gitlab/python-gitlab/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ nyanloutre ];
    mainProgram = "gitlab";
  };
}
