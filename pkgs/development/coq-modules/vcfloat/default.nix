{
  lib,
  bignums,
  compcert,
  coq,
  flocq,
  interval,
  mkCoqDerivation,
  version ? null,
}:

let
  self = mkCoqDerivation {
    inherit version;
    pname = "vcfloat";

    postPatch = ''
      coq_makefile -o Makefile -f _CoqProject *.v
    '';

    propagatedBuildInputs = [
      interval
      compcert
      flocq
      bignums
    ];

    defaultVersion =
      with lib.versions;
      lib.switch coq.coq-version [
        {
          case = isEq "8.20";
          out = "2.3";
        }
        {
          case = isEq "8.19";
          out = "2.2";
        }
        {
          case = range "8.16" "8.18";
          out = "2.1.1";
        }
      ] null;

    owner = "VeriNum";
    release."2.1.1".hash = "sha256-bd/XSQhyFUAnSm2bhZEZBWB6l4/Ptlm9JrWu6w9BOpw=";
    release."2.2".hash = "sha256-PyMm84ZYh+dOnl8Kk2wlYsQ+S/d1Hsp6uv2twTedEPg=";
    release."2.3".hash = "sha256-fV7w/kYTpcBxrHFzEvx+eydDHbGH05/seucrgSjKK3w=";
    releaseRev = v: "v${v}";
    sourceRoot = "${self.src.name}/vcfloat";

    meta = {
      description = "Tool for Coq proofs about floating-point round-off error";
      license = lib.licenses.lgpl3Plus;
      maintainers = with lib.maintainers; [ quinn-dougherty ];
    };
  };
in
self
