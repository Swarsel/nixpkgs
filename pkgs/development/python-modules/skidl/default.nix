{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  future,
  graphviz,
  kinparse,
  pyspice,
  sexpdata,
}:
buildPythonPackage rec {
  pname = "skidl";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "devbisme";
    repo = "skidl";
    tag = "v${version}";
    sha256 = "sha256-7rauFhaLXyZ5SGtEF7qoAbrj/VgP4qpl+BWUeERefb4=";
  };

  propagatedBuildInputs = [
    future
    kinparse
    pyspice
    graphviz
    sexpdata
  ];

  # Checks require availability of the kicad symbol libraries.
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "skidl" ];

  meta = {
    description = "SKiDL is a module that extends Python with the ability to design electronic circuits";
    homepage = "https://devbisme.github.io/skidl/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ matthuszagh ];
    mainProgram = "netlist_to_skidl";
  };
}
