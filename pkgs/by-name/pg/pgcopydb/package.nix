{
  lib,
  fetchFromGitHub,
  boehmgc,
  clangStdenv,
  libkrb5,
  openssl,
  pam,
  pkg-config,
  postgresql,
  python3Packages,
  readline,
  sqlite,
  testers,
  zlib,
}:

clangStdenv.mkDerivation (finalAttrs: {
  pname = "pgcopydb";
  version = "0.17-unstable-2026-05-21";

  src = fetchFromGitHub {
    owner = "dimitri";
    repo = "pgcopydb";
    rev = "984269274ccdaf0d297ed82db635e6746be55b75";
    hash = "sha256-qTtziRdsge4YtQTTfWQ5KD8SQn2HYnj3rDMcrbI56SY=";
  };

  nativeBuildInputs = [
    pkg-config
    postgresql.pg_config
  ];

  buildInputs = postgresql.buildInputs ++ [
    boehmgc
    postgresql
    sqlite
    python3Packages.sphinxHook
  ];

  installPhase = ''
    runHook preInstall

    install -D -t $out/bin/ src/bin/pgcopydb/pgcopydb

    runHook postInstall
  '';

  hardeningDisable = [ "format" ];

  sphinxBuilders = [
    "man"
  ];

  passthru.tests = {
    version = testers.testVersion {
      package = finalAttrs.finalPackage;
    };
  };

  meta = {
    description = "Copy a Postgres database to a target Postgres server (pg_dump | pg_restore on steroids";
    homepage = "https://github.com/dimitri/pgcopydb";
    changelog = "https://github.com/dimitri/pgcopydb/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.postgresql;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "pgcopydb";
  };
})
