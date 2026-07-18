{
  lib,
  coq,
  mkCoqDerivation,
  stdlib,
  version ? null,
}:

(mkCoqDerivation {
  inherit version;
  pname = "tlc";
  propagatedBuildInputs = [ stdlib ];

  defaultVersion =
    with lib.versions;
    lib.switch coq.coq-version [
      {
        case = range "8.13" "8.16";
        out = "20211215";
      }
      {
        case = range "8.12" "8.13";
        out = "20210316";
      }
      {
        case = range "8.10" "8.12";
        out = "20200328";
      }
      {
        case = range "8.6" "8.12";
        out = "20181116";
      }
    ] null;

  displayVersion = {
    tlc = false;
  };

  owner = "charguer";
  release."20181116".hash = "sha256:032lrbkxqm9d3fhf6nv1kq2z0mqd3czv3ijlbsjwnfh12xck4vpl";
  release."20200328".hash = "sha256:16vzild9gni8zhgb3qhmka47f8zagdh03k6nssif7drpim8233lx";
  release."20210316".hash = "sha256:1hlavnx20lxpf2iydbbxqmim9p8wdwv4phzp9ypij93yivih0g4a";
  release."20211215".hash = "sha256:0m4d4jhdcyq8p2gpz9j3nd6jqzmz2bjmbpc0q06b38b8i550mamp";

  meta = {
    description = "Non-constructive library for Coq";
    homepage = "http://www.chargueraud.org/softs/tlc/";
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.vbgl ];
  };
}).overrideAttrs
  (
    x:
    lib.optionalAttrs (lib.versionOlder x.version "20210316" && x.version != "dev") {
      installFlags = [ "CONTRIB=$(out)/lib/coq/${coq.coq-version}/user-contrib" ];
    }
  )
