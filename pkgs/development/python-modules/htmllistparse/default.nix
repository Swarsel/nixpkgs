{
  lib,
  beautifulsoup4,
  buildPythonPackage,
  fetchPypi,
  fusepy,
  html5lib,
  requests,
  setuptools,
}:

buildPythonPackage rec {
  pname = "htmllistparse";
  version = "0.6.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-bcimvwPIQ7nTJYQ6JqI1GnlbVzzZKiybgnFiEBnGQII=";
  };

  nativeBuildInputs = [ setuptools ];

  propagatedBuildInputs = [
    beautifulsoup4
    html5lib
    requests
    fusepy
  ];

  # upstream has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "htmllistparse" ];

  meta = {
    description = "Python parser for Apache/nginx-style HTML directory listing";
    homepage = "https://github.com/gumblex/htmllisting-parser";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "rehttpfs";
  };
}
