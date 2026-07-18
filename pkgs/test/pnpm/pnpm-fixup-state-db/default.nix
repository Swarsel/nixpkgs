{
  pnpm-fixup-state-db,
  sqlite,
  testers,
}:
testers.runCommand {
  nativeBuildInputs = [
    pnpm-fixup-state-db
    sqlite
  ];

  hash = "sha256-P3PDQAziwUxl2pfYV+QyPVwNpq90Jg46bawTvrT0NOQ=";
  name = "pnpm-fixup-state-db-test";

  script = ''
    install -Dm644 ${./index.db} ./store/index.db

    pnpm-fixup-state-db ./store

    cp ./store/index.db $out
  '';
}
