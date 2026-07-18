{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  git,
  gnutar,
  gzip,
  makeWrapper,
  r10k,
  testers,
}:

bundlerApp rec {
  pname = "r10k";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram $out/bin/r10k --prefix PATH : ${
      lib.makeBinPath [
        git
        gnutar
        gzip
      ]
    }
  '';

  exes = [ "r10k" ];
  gemdir = ./.;

  passthru = {
    tests.version = testers.testVersion {
      version = (import ./gemset.nix).r10k.version;
      command = "${lib.getExe r10k} version";
      package = r10k;
    };

    updateScript = bundlerUpdateScript pname;
  };

  meta = {
    description = "Puppet environment and module deployment";
    homepage = "https://github.com/puppetlabs/r10k";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      zimbatm
      nicknovitski
      anthonyroussel
    ];

    platforms = lib.platforms.unix;
    mainProgram = "r10k";
  };
}
