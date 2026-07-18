{
  lib,
  stdenv,
  fetchurl,
  angstrom,
  bigstringaf,
  buildDunePackage,
  darwin,
  domain-name,
  dune-site,
  ipaddr,
  logs,
  lru,
  lwt-dllist,
  mtime,
  ptime,
  uri,
}:

buildDunePackage (finalAttrs: {
  pname = "caqti";
  version = "2.3.2";

  src = fetchurl {
    url = "https://github.com/paurkedal/ocaml-caqti/releases/download/v${finalAttrs.version}/caqti-v${finalAttrs.version}.tbz";
    hash = "sha256-j2wXJLWawipcZXyeU7mhcG457NRi6ClYsM6ojkPwq6c=";
  };

  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ darwin.sigtool ];
  buildInputs = [ dune-site ];

  propagatedBuildInputs = [
    angstrom
    bigstringaf
    domain-name
    ipaddr
    logs
    lru
    lwt-dllist
    mtime
    ptime
    uri
  ];

  # Checks depend on caqti-driver-sqlite3 (circural dependency)
  doCheck = false;
  minimalOCamlVersion = "4.08";

  meta = {
    description = "Unified interface to relational database libraries";
    homepage = "https://github.com/paurkedal/ocaml-caqti";

    license = with lib.licenses; [
      lgpl3Plus
      ocamlLgplLinkingException
    ];

    maintainers = with lib.maintainers; [ bcc32 ];
  };
})
