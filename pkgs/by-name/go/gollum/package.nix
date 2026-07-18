{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  makeWrapper,
  nixosTests,
  ruby,
}:

bundlerApp {
  inherit ruby;
  pname = "gollum";
  nativeBuildInputs = [ makeWrapper ];
  exes = [ "gollum" ];
  gemdir = ./.;
  passthru.tests.gollum = nixosTests.gollum;
  passthru.updateScript = bundlerUpdateScript "gollum";

  meta = {
    description = "Simple, Git-powered wiki with a sweet API and local frontend";
    homepage = "https://github.com/gollum/gollum";
    changelog = "https://github.com/gollum/gollum/blob/HEAD/HISTORY.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      erictapen
      jgillich
      nicknovitski
      bbenno
    ];

    platforms = lib.platforms.unix;
    mainProgram = "gollum";
  };
}
