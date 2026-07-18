{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  gnumake,
  makeWrapper,
  pdk,
  testers,
}:

bundlerApp {
  pname = "pdk";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/pdk --prefix PATH : ${lib.makeBinPath [ gnumake ]}
  '';

  exes = [ "pdk" ];
  gemdir = ./.;

  passthru = {
    tests.version = testers.testVersion {
      version = (import ./gemset.nix).pdk.version;
      package = pdk;
    };

    updateScript = bundlerUpdateScript "pdk";
  };

  meta = {
    description = "Puppet Development Kit";
    homepage = "https://github.com/puppetlabs/pdk";
    changelog = "https://github.com/puppetlabs/pdk/blob/main/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      netali
      anthonyroussel
    ];

    mainProgram = "pdk";
  };
}
