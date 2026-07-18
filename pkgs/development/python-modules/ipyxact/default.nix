{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  lxml,
  pyyaml,
  six,
}:

buildPythonPackage rec {
  pname = "ipyxact";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "olofk";
    repo = "ipyxact";
    rev = "v${version}";
    hash = "sha256-myD+NnqcxxaSAV7qZa8xqeciaiFqFePqIzd7sb/2GXA=";
  };

  propagatedBuildInputs = [ pyyaml ];

  checkInputs = [
    six
    lxml
  ];

  format = "setuptools";
  pythonImportsCheck = [ "ipyxact" ];

  meta = {
    description = "IP-XACT parser";
    homepage = "https://github.com/olofk/ipyxact";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "ipxact2v";
  };
}
