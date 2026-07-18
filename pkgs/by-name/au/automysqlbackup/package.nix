{
  lib,
  stdenv,
  fetchFromGitHub,
  bzip2,
  gzip,
  mailutils,
  makeWrapper,
  mariadb,
  pbzip2,
  pigz,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "automysqlbackup";
  version = "3.0.7";

  src = fetchFromGitHub {
    owner = "sixhop";
    repo = "automysqlbackup";
    tag = finalAttrs.version;
    sha256 = "sha256-C0p1AY4yIxybQ6a/HsE3ZTHumtvQw5kKM51Ap+Se0ZI=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/etc

    cp automysqlbackup $out/bin/
    cp automysqlbackup.conf $out/etc/

    wrapProgram $out/bin/automysqlbackup --prefix PATH : ${
      lib.makeBinPath [
        mariadb
        mailutils
        pbzip2
        pigz
        bzip2
        gzip
      ]
    }
  '';

  meta = {
    description = "Script to run daily, weekly and monthly backups for your MySQL database";
    homepage = "https://github.com/sixhop/AutoMySQLBackup";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.aanderse ];
    platforms = lib.platforms.linux;
    mainProgram = "automysqlbackup";
  };
})
