{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  graphviz,
  pandoc,
  plantuml,
  pydal,
}:

buildPythonPackage rec {
  pname = "pytm";
  version = "1.3.1";

  src = fetchFromGitHub {
    owner = "OWASP";
    repo = "pytm";
    tag = "v${version}";
    sha256 = "sha256-MseV1ucDCzSM36zx04g9v5euDX0t74KqUSB4+brHzt8=";
  };

  propagatedBuildInputs = [
    pydal
    graphviz
    pandoc
    plantuml
  ];

  format = "setuptools";
  pythonImportsCheck = [ "pytm" ];

  meta = {
    description = "Pythonic framework for threat modeling";
    homepage = "https://owasp.org/www-project-pytm/";

    license = with lib.licenses; [
      capec
      mit
    ];

    maintainers = with lib.maintainers; [ wamserma ];
  };
}
