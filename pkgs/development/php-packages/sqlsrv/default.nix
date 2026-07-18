{
  lib,
  stdenv,
  buildPecl,
  libiconv,
  unixodbc,
}:
buildPecl {
  pname = "sqlsrv";
  version = "5.13.0";
  buildInputs = [ unixodbc ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  sha256 = "sha256-MdbCg1oFp7btDw3bZ1VsqRRlKlelccJokfAtitmbflw=";

  meta = {
    description = "Microsoft Drivers for PHP for SQL Server";
    homepage = "https://github.com/Microsoft/msphpsql";
    license = lib.licenses.mit;
    teams = [ lib.teams.php ];
  };
}
