{
  lib,
  fetchurl,
}:
let
  version = "2025-08-16";
in
fetchurl {
  inherit version;
  pname = "cellservdb";
  hash = "sha256-Rb6DBb9to7x5ya2ywx+wTls2c9GQmV0v5z9rmZ78dDs=";
  url = "https://grand.central.org/dl/cellservdb/CellServDB.${version}";

  meta = {
    description = "GRAND.CENTRAL.ORG Public CellServDB";
    homepage = "https://grand.central.org/csdb.html";
    # As a database, CellServDB is not copywritten.
    license = lib.licenses.publicDomain;

    maintainers = [
      lib.maintainers.quentin
    ];
  };
}
