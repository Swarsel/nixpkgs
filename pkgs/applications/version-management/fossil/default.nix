{
  lib,
  stdenv,
  fetchurl,
  buildPackages,
  ed,
  installShellFiles,
  libiconv,
  openssl,
  readline,
  sqlite,
  tcl,
  tclPackages,
  which,
  zlib,
  withInternalSqlite ? true,
  withJson ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fossil";
  version = "2.28";

  src = fetchurl {
    url = "https://www.fossil-scm.org/home/tarball/version-${finalAttrs.version}/fossil-${finalAttrs.version}.tar.gz";
    hash = "sha256-y5joXR+QZAyYniRSHpD+vJjtjuPyZj2Lg6RFsVvMg9M=";
  };

  nativeBuildInputs = [
    installShellFiles
    tcl
  ];

  buildInputs = [
    zlib
    openssl
    readline
    which
    ed
  ]
  ++ lib.optional stdenv.hostPlatform.isDarwin libiconv
  ++ lib.optional (!withInternalSqlite) sqlite;

  configureFlags =
    lib.optional (!withInternalSqlite) "--disable-internal-sqlite" ++ lib.optional withJson "--json";

  preBuild = ''
    export USER=nonexistent-but-specified-user
  '';

  doCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;

  postInstall = ''
    installManPage fossil.1
    installShellCompletion --cmd fossil tools/fossil-autocomplete.{bash,zsh}
  '';

  # required for build time tool `./tools/translate.c`
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  installFlags = [ "INSTALLDIR=$(out)/bin" ];

  meta = {
    description = "Simple, high-reliability, distributed software configuration management";

    longDescription = ''
      Fossil is a software configuration management system.  Fossil is
      software that is designed to control and track the development of a
      software project and to record the history of the project. There are
      many such systems in use today. Fossil strives to distinguish itself
      from the others by being extremely simple to setup and operate.
    '';

    homepage = "https://www.fossil-scm.org/";
    license = lib.licenses.bsd2;
    platforms = lib.platforms.all;
    mainProgram = "fossil";
  };
})
