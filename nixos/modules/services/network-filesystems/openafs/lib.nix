{ config, lib, ... }:

let
  inherit (lib)
    concatStringsSep
    concatMapAttrsStringSep
    mkOption
    types
    optionalString
    ;
  cellServDBMemberType = types.submodule {
    options = {
      dnsname = mkOption {
        default = "";
        description = "DNS full-qualified domain name of a database server";
        example = "afs.example.org";
        type = types.str;
      };

      ip = mkOption {
        default = "";
        description = "IP Address of a database server";
        example = "1.2.3.4";
        type = types.str;
      };
    };
  };
  cellServDBCellType = types.listOf cellServDBMemberType;
in
{

  # CellServDB configuration type
  cellServDBType =
    thisCell:
    types.coercedTo (types.listOf types.anything) (m: { "${thisCell}" = m; }) (
      types.attrsOf cellServDBCellType
    );

  mkCellServDB = concatMapAttrsStringSep "" (
    cellName: db:
    ''
      >${cellName}
    ''
    + (concatStringsSep "\n" (
      map (dbm: optionalString (dbm.ip != "" && dbm.dnsname != "") "${dbm.ip} #${dbm.dnsname}") db
    ))
    + "\n"
  );

  openafsBin = config.services.openafsClient.packages.programs;
  openafsMod = config.services.openafsClient.packages.module;
  openafsSrv = config.services.openafsServer.package;
}
