{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  cmdliner,
  findlib,
}:

buildDunePackage rec {
  pname = "ocp-indent";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "OCamlPro";
    repo = "ocp-indent";
    tag = version;
    hash = "sha256-71dbZ8c842MYZfHad6RT0E48JlgzJSHnQgLVA5dGLv8=";
  };

  buildInputs = [ cmdliner ];
  propagatedBuildInputs = [ findlib ];
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Customizable tool to indent OCaml code";
    homepage = "https://www.typerex.org/ocp-indent.html";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.jirkamarsik ];
    mainProgram = "ocp-indent";
  };
}
