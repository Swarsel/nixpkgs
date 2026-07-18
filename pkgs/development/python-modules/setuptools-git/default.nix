{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  gitMinimal,
  replaceVars,
  setuptools,
}:

buildPythonPackage rec {
  pname = "setuptools-git";
  version = "1.2";

  src = fetchFromGitHub {
    owner = "msabramo";
    repo = "setuptools-git";
    tag = version;
    hash = "sha256-dbQ15y62nanuWgh2puLYSio391Ja3SF+HrafvTBVNbk=";
  };

  patches = [
    (replaceVars ./hardcode-git-path.patch {
      git = lib.getExe gitMinimal;
    })
  ];

  doCheck = false;
  build-system = [ setuptools ];
  pyproject = true;

  meta = {
    description = "Setuptools revision control system plugin for Git";
    homepage = "https://github.com/msabramo/setuptools-git";
    license = lib.licenses.bsd3;
  };
}
