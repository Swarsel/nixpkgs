{
  coq,
  coq-hammer-tactics,
  mkCoqDerivation,
  version ? null,
}:

mkCoqDerivation {
  inherit version;

  inherit (coq-hammer-tactics)
    owner
    repo
    defaultVersion
    release
    releaseRev
    ;

  pname = "coq-hammer";

  propagatedBuildInputs = [
    coq.ocamlPackages.findlib
    coq-hammer-tactics
  ];

  buildFlags = [ "plugin" ];
  extraInstallFlags = [ "BINDIR=$(out)/bin/" ];
  installTargets = [ "install-plugin" ];
  mlPlugin = true;

  meta = coq-hammer-tactics.meta // {
    description = "General-purpose automated reasoning hammer tool for Coq";
  };
}
