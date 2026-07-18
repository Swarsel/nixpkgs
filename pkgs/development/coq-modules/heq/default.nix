{
  lib,
  coq,
  fetchzip,
  mkCoqDerivation,
  version ? null,
}:

let
  fetcher =
    {
      domain,
      hash,
      owner,
      repo,
      rev,
      ...
    }:
    fetchzip {
      inherit hash;
      url = "https://${domain}/${owner}/${repo}/download/${repo}-${rev}.zip";
    };
in
mkCoqDerivation {
  inherit version fetcher;
  pname = "heq";
  preBuild = "cd src";
  defaultVersion = if lib.versions.isLt "8.8" coq.coq-version then "0.92" else null;
  domain = "sf.snu.ac.kr";
  extraInstallFlags = [ "COQLIB=$(out)/lib/coq/${coq.coq-version}/" ];
  mlPlugin = true;
  owner = "gil.hur";
  release."0.92".hash = "sha256:0cf8y6728n81wwlbpq3vi7l2dbzi7759klypld4gpsjjp1y1fj74";
  repo = "Heq";

  meta = {
    description = "Heq : a Coq library for Heterogeneous Equality";
    homepage = "https://ropas.snu.ac.kr/~gil.hur/Heq/";
    maintainers = with lib.maintainers; [ jwiegley ];
  };
}
