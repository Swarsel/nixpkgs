{
  lib,
  stdenv,
  fetchFromGitHub,
  findutils,
  gawk,
  gnugrep,
  gnused,
  mariadb,
  postgresql,
  sqlite,
  withMySQL ? true,
  withPSQL ? false,
  withSQLite ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "shmig";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "mbucc";
    repo = "shmig";
    rev = "v${finalAttrs.version}";
    sha256 = "15ry1d51d6dlzzzhck2x57wrq48vs4n9pp20bv2sz6nk92fva5l5";
  };

  postPatch = ''
    patchShebangs .

    substituteInPlace shmig \
      --replace "\`which mysql\`" "${lib.optionalString withMySQL "${mariadb.client}/bin/mysql"}" \
      --replace "\`which psql\`" "${lib.optionalString withPSQL "${postgresql}/bin/psql"}" \
      --replace "\`which sqlite3\`" "${lib.optionalString withSQLite "${sqlite}/bin/sqlite3"}" \
      --replace "awk" "${gawk}/bin/awk" \
      --replace "grep" "${gnugrep}/bin/grep" \
      --replace "find" "${findutils}/bin/find" \
      --replace "sed" "${gnused}/bin/sed"
  '';

  makeFlags = [ "PREFIX=$(out)" ];

  preBuild = ''
    mkdir -p $out/bin
  '';

  meta = {
    description = "Minimalistic database migration tool with MySQL, PostgreSQL and SQLite support";
    homepage = "https://github.com/mbucc/shmig";
    license = lib.licenses.bsd3;
    maintainers = [ ];
    mainProgram = "shmig";
  };
})
