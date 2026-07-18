{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  runCommand,
  sqlint,
}:

bundlerApp {
  pname = "sqlint";
  exes = [ "sqlint" ];
  gemdir = ./.;

  passthru = {
    tests.help = runCommand "sqlint-help-test" { } ''
      ${sqlint}/bin/sqlint --help
      touch $out
    '';

    updateScript = bundlerUpdateScript "sqlint";
  };

  meta = {
    description = "Simple SQL linter";
    homepage = "https://github.com/purcell/sqlint";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ariutta
      nicknovitski
      purcell
    ];

    platforms = lib.platforms.unix;
  };
}
