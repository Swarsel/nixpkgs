{
  lib,
  stdenv,
  buildPecl,
  libiconv,
  php,
  unixodbc,
}:
buildPecl {
  pname = "pdo_sqlsrv";
  version = "5.13.0";
  buildInputs = [ unixodbc ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  internalDeps = [ php.extensions.pdo ];
  sha256 = "sha256-76hZvMSNl/JSaNvevx2yXyVhDX+jaz7pEHPByZQR4kw=";

  meta = {
    description = "Microsoft Drivers for PHP for SQL Server";
    homepage = "https://github.com/Microsoft/msphpsql";
    license = lib.licenses.mit;
    broken = lib.versionAtLeast php.version "8.5";
    teams = [ lib.teams.php ];
  };
}
