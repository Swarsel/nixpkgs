{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  js_of_ocaml,
  lwt,
  lwt_ppx,
}:

buildDunePackage (finalAttrs: {
  pname = "ocsipersist-lib";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ocsigen";
    repo = "ocsipersist";
    tag = finalAttrs.version;
    hash = "sha256-YJzfgeyNXgBXAK607ROUXUmSpMKYx63ofZaBB8dnsq4=";
  };

  buildInputs = [ lwt_ppx ];

  propagatedBuildInputs = [
    js_of_ocaml
    lwt
  ];

  minimalOCamlVersion = "4.13";

  meta = {
    description = "Persistent key/value storage (for Ocsigen) - support library";
    homepage = "https://github.com/ocsigen/ocsipersist/";
    license = lib.licenses.lgpl21Only;
    maintainers = [ lib.maintainers.vbgl ];
  };
})
