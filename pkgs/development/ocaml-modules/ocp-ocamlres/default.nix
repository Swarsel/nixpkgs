{
  lib,
  stdenv,
  fetchFromGitHub,
  astring,
  findlib,
  ocaml,
  pprint,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-ocp-ocamlres";
  version = "0.4";

  src = fetchFromGitHub {
    owner = "OCamlPro";
    repo = "ocp-ocamlres";
    rev = "v${version}";
    sha256 = "0smfwrj8qhzknhzawygxi0vgl2af4vyi652fkma59rzjpvscqrnn";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
  ];

  buildInputs = [
    astring
    pprint
  ];

  preInstall = "mkdir -p $out/bin";
  createFindlibDestdir = true;
  installFlags = [ "BINDIR=$(out)/bin" ];

  meta = {
    inherit (ocaml.meta) platforms;
    description = "Simple tool and library to embed files and directories inside OCaml executables";
    homepage = "https://www.typerex.org/ocp-ocamlres.html";
    license = lib.licenses.lgpl3Plus;
    maintainers = [ lib.maintainers.vbgl ];
    mainProgram = "ocp-ocamlres";
    broken = lib.versionOlder ocaml.version "4.02";
  };
}
