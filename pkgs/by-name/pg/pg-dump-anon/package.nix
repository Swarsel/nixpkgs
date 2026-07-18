{
  lib,
  fetchFromGitLab,
  buildGoModule,
  makeWrapper,
  nixosTests,
  postgresql,
}:

buildGoModule (finalAttrs: {
  pname = "pg-dump-anon";
  version = "2.4.1";

  src = fetchFromGitLab {
    owner = "dalibo";
    repo = "postgresql_anonymizer";
    tag = finalAttrs.version;
    hash = "sha256-vAsKTkFx8HLKDdXIQt6fEF3l7EzzvcilGfqNtBa0AMM=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-CwU1zoIayxvfnGL9kPdummPJiV+ECfSz4+q6gZGb8pw=";

  postInstall = ''
    wrapProgram $out/bin/pg_dump_anon \
      --prefix PATH : ${lib.makeBinPath [ postgresql ]}
  '';

  sourceRoot = "${finalAttrs.src.name}/pg_dump_anon";
  passthru.tests = { inherit (nixosTests.postgresql) anonymizer; };

  meta = {
    description = "Export databases with data being anonymized with the anonymizer extension";
    homepage = "https://postgresql-anonymizer.readthedocs.io/en/stable/";
    license = lib.licenses.postgresql;

    maintainers = [
      lib.maintainers.leona
      lib.maintainers.osnyx
    ];

    mainProgram = "pg_dump_anon";
  };
})
