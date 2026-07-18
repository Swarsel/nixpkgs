{
  lib,
  fetchurl,
  buildDunePackage,
  ctypes,
  dune-configurator,
  libmysqlclient,
  mariadb,
}:

buildDunePackage (finalAttrs: {
  pname = "mariadb";
  version = "1.3.0";

  src = fetchurl {
    url = "https://github.com/ocaml-community/ocaml-mariadb/releases/download/${finalAttrs.version}/mariadb-${finalAttrs.version}.tbz";
    hash = "sha256-mYktFTUDaA///SzTMgQDNXtYiXxnkMrf4EujijpmjMY=";
  };

  buildInputs = [
    mariadb
    libmysqlclient
    dune-configurator
  ];

  propagatedBuildInputs = [ ctypes ];

  meta = {
    description = "OCaml bindings for MariaDB";
    homepage = "https://github.com/ocaml-community/ocaml-mariadb";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bcc32 ];
  };
})
