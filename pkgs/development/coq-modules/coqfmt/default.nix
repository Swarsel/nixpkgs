{
  lib,
  coq,
  coq-lsp,
  makeWrapper,
  mkCoqDerivation,
  ocamlPackages,
  version ? null,
}:

mkCoqDerivation rec {
  inherit version;
  pname = "coqfmt";
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = with ocamlPackages; [
    dune-build-info
    coq-lsp
  ];

  installPhase = ''
    runHook preInstall
    dune install -p ${pname} --prefix=$out --libdir $OCAMLFIND_DESTDIR
    wrapProgram $out/bin/coqfmt --prefix OCAMLPATH : $OCAMLPATH
    runHook postInstall
  '';

  defaultVersion =
    with lib.versions;
    lib.switch coq.version [
      {
        case = isEq "8.20";
        out = "master";
      }
    ] null;

  displayVersion.coqfmt = v: "master-${v}";
  namePrefix = [ ];
  owner = "toku-sa-n";

  release."master" = {
    hash = "sha256-4Q0z/KUHrJZKeKJDqa9mkxfy9LrGh2xPt561muUFYAY=";
    rev = "c26ce64d6ad1a1c3cafee38ab4889ad3b68a5c33";
  };

  useDune = true;

  meta = {
    description = "CLI tool to format your Coq source code";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ DieracDelta ];
  };

}
