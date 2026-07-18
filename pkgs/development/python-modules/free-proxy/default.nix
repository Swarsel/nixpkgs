{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  pip-chill,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "free-proxy";
  version = "1.2.1";

  src = fetchFromGitHub {
    owner = "jundymek";
    repo = "free-proxy";
    tag = "v${version}";
    hash = "sha256-Q8102tnssVnIYEP9fBOBFSSsZqTGGulalyAkvnlp3UY=";
  };

  build-system = [ setuptools ];

  dependencies = [
    pip-chill
    lxml
    requests
  ];

  pyproject = true;

  meta = {
    description = "Free proxy scraper written in python";
    homepage = "https://github.com/jundymek/free-proxy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tochiaha ];
  };
}
