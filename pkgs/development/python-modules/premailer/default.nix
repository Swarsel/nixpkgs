{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cachetools,
  cssselect,
  cssutils,
  lxml,
  requests,
  setuptools,
}:

buildPythonPackage {
  pname = "premailer";
  version = "3.10.0";

  src = fetchFromGitHub {
    owner = "peterbe";
    repo = "premailer";
    rev = "f4ded0b9701c4985e7ff5c5beda83324c264ea62";
    hash = "sha256-8ALdpR3aIDg0wP+JYCPY1f7mEJgdJm8xlLlgGpa0Sa4=";
  };

  build-system = [ setuptools ];

  dependencies = [
    lxml
    cssselect
    cssutils
    requests
    cachetools
  ];

  pyproject = true;
  pythonImportsCheck = [ "premailer" ];

  meta = {
    description = "Turns CSS blocks into style attributes";
    homepage = "https://github.com/peterbe/premailer";
    changelog = "https://github.com/peterbe/premailer/blob/master/CHANGES.rst";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.linsui ];
  };
}
