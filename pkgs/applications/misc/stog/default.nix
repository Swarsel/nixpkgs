{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  dune-build-info,
  dune-site,
  fmt,
  higlo,
  logs,
  lwt,
  lwt_ppx,
  menhir,
  ocf,
  ocf_ppx,
  ppx_blob,
  ptime,
  uri,
  uutf,
  xtmpl,
  xtmpl_ppx,
}:

buildDunePackage rec {
  pname = "stog";
  version = "1.1.0";

  src = fetchFromGitLab {
    owner = "zoggy";
    repo = "stog";
    tag = version;
    hash = "sha256-seaVco5AoOxjEuw8zYsrA25vcyo1Un3eUJUU9FT57WU=";
    domain = "framagit.org";
  };

  nativeBuildInputs = [ menhir ];

  buildInputs = [
    lwt_ppx
    ocf_ppx
    ppx_blob
    xtmpl_ppx
  ];

  propagatedBuildInputs = [
    dune-build-info
    dune-site
    fmt
    higlo
    logs
    lwt
    ocf
    ptime
    uri
    uutf
    xtmpl
  ];

  minimalOCamlVersion = "4.13";

  meta = {
    description = "XML documents and web site compiler";
    homepage = "https://www.good-eris.net/stog";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ regnat ];
  };
}
