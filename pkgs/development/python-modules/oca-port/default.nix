{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  click,
  git-filter-repo,
  gitpython,
  giturlparse,
  nix-update-script,
  requests,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "oca-port";
  version = "0.22";

  src = fetchFromGitHub {
    inherit version;
    owner = "OCA";
    repo = "oca-port";
    tag = "v${version}";
    hash = "sha256-8YaWgbq75bvUdnMdgdqNZkPDKZ5PgQ3qYHBeIliyCzI=";
  };

  build-system = [
    setuptools-scm
  ];

  dependencies = [
    click
    giturlparse
    gitpython
    requests
    git-filter-repo
  ];

  pyproject = true;
  pythonImportsCheck = [ "oca_port" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool helping to port an addon or missing commits of an addon from one branch to another";
    homepage = "https://github.com/OCA/oca-port";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ yajo ];
  };
}
