{
  lib,
  fetchPypi,
  python3,
}:

python3.pkgs.buildPythonPackage rec {
  pname = "rst2html5";
  version = "2.0.1";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-MJmYyF+rAo8vywGizNyIbbCvxDmCYueVoC6pxNDzKuk=";
  };

  # Tests are not shipped as PyPI releases
  doCheck = false;
  build-system = with python3.pkgs; [ poetry-core ];

  dependencies = with python3.pkgs; [
    beautifulsoup4
    docutils
    genshi
    pygments
  ];

  pyproject = true;
  pythonImportsCheck = [ "rst2html5" ];

  meta = {
    description = "Converts ReSTructuredText to (X)HTML5";
    homepage = "https://rst2html5.readthedocs.io/";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "rst2html5";
  };
}
