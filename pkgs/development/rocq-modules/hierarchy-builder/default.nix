{
  lib,
  mkRocqDerivation,
  rocq-core,
  rocq-elpi,
  version ? null,
}:

let
  hb = mkRocqDerivation {
    inherit version;
    pname = "hierarchy-builder";
    propagatedBuildInputs = [ rocq-elpi ];

    defaultVersion =
      let
        case = case: out: { inherit case out; };
      in
      with lib.versions;
      lib.switch rocq-core.rocq-version [
        (case (range "9.0" "9.2") "1.10.3")
        (case (range "9.0" "9.1") "1.10.2")
        (case (range "9.0" "9.1") "1.10.0")
        (case (range "9.0" "9.1") "1.9.1")
      ] null;

    owner = "math-comp";
    release."1.10.0".sha256 = "sha256-c52nS8I0tia7Q8lZTFJyHVPVabW9xv55m7w6B7y3+e8=";
    release."1.10.2".sha256 = "sha256-Uzni9qrYQP45Tr+JkHs0BuRARwmWSMwA/iHhIzkolxc=";
    release."1.10.3".hash = "sha256-y13KxzLulIu39Ci3aMc1cZG4tw3LL2ab7U9snI6jrXc=";
    release."1.9.1".sha256 = "sha256-AiS0ezMyfIYlXnuNsVLz1GlKQZzJX+ilkrKkbo0GrF0=";
    releaseRev = v: "v${v}";

    meta = {
      description = "High level commands to declare a hierarchy based on packed classes";
      license = lib.licenses.mit;

      maintainers = with lib.maintainers; [
        cohencyril
        siraben
      ];
    };
  };
in
hb.overrideAttrs (
  o:
  lib.optionalAttrs (o.version == "1.9.1") { installFlags = [ "DESTDIR=$(out)" ] ++ o.installFlags; }
)
