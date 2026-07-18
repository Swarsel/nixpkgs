{
  lib,
  stdenv,
  fetchFromGitHub,
  base64,
  camlp4,
  cstruct,
  digestif,
  erm_xml,
  findlib,
  mirage-crypto,
  mirage-crypto-rng,
  ocaml,
  ocamlbuild,
}:

stdenv.mkDerivation {
  pname = "ocaml${ocaml.version}-erm_xmpp";
  version = "0.3+20241009";

  src = fetchFromGitHub {
    owner = "hannesm";
    repo = "xmpp";
    rev = "54418f77abf47b175e9c1b68a4f745a12b640d6a";
    sha256 = "sha256-AbzZjNkW1VH/FOnzNruvelZeo3IYg/Usr3enQEknTQs=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    ocaml
    findlib
    ocamlbuild
    camlp4
  ];

  buildInputs = [ camlp4 ];

  propagatedBuildInputs = [
    cstruct
    erm_xml
    mirage-crypto
    mirage-crypto-rng
    base64
    digestif
  ];

  buildPhase = ''
    runHook preBuild
    ocaml setup.ml -build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    ocaml setup.ml -install
    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure
    ocaml setup.ml -configure --prefix $out
    runHook postConfigure
  '';

  createFindlibDestdir = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml based XMPP implementation (fork)";
    homepage = "https://github.com/hannesm/xmpp";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ sternenseemann ];
  };
}
