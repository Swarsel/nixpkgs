{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  libpq,
  ruby_3_4,
  sqlite,
  withPostgresql ? true,
  withSqlite ? false,
}:

bundlerApp {
  pname = "ledger_web";
  buildInputs = lib.optional withPostgresql libpq ++ lib.optional withSqlite sqlite;
  exes = [ "ledger_web" ];
  gemdir = ./.;
  # "Source locally installed gems is ignoring... because it is missing extensions"
  ruby = ruby_3_4;
  passthru.updateScript = bundlerUpdateScript "ledger-web";

  meta = {
    description = "Web frontend to the Ledger CLI tool";
    homepage = "https://github.com/peterkeen/ledger-web";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.linux;
    mainProgram = "ledger_web";
  };
}
