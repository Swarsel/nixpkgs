{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "cucumber";
  exes = [ "cucumber" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "cucumber";

  meta = {
    description = "Tool for executable specifications";
    homepage = "https://cucumber.io/";
    changelog = "https://github.com/cucumber/cucumber-ruby/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
      anthonyroussel
    ];

    platforms = lib.platforms.unix;
    mainProgram = "cucumber";
  };
}
