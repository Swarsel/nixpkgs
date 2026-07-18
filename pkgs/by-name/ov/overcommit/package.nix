{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  git,
  makeWrapper,
  overcommit,
  testers,
}:

bundlerApp {
  pname = "overcommit";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/overcommit --prefix PATH : ${lib.makeBinPath [ git ]}
  '';

  exes = [ "overcommit" ];
  gemdir = ./.;

  passthru = {
    tests.version = testers.testVersion {
      version = (import ./gemset.nix).overcommit.version;
      package = overcommit;
    };

    updateScript = bundlerUpdateScript "overcommit";
  };

  meta = {
    description = "Tool to manage and configure Git hooks";
    homepage = "https://github.com/sds/overcommit";
    changelog = "https://github.com/sds/overcommit/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      anthonyroussel
    ];

    platforms = lib.platforms.unix;
    mainProgram = "overcommit";
  };
}
