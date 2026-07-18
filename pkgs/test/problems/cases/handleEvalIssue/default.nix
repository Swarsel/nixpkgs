{
  nixpkgs ? ../../../../..,
}:
let
  pkgs = import nixpkgs {
    config = {
      checkMeta = true;
      handleEvalIssue = reason: errormsg: builtins.trace "reason: ${reason}, errormsg: ${errormsg}" true;

      problems.matchers = [
        {
          handler = "error";
          kind = "deprecated";
        }
        {
          handler = "error";
          kind = "removal";
        }
      ];
    };

    overlays = [ ];
    system = "x86_64-linux";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "a";
  version = "0";
  meta.description = "Some package";
  meta.problems.deprecated.message = "To be deprecated.";
  meta.problems.removal.message = "To be removed.";
}
