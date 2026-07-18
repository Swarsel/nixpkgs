{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  defaultGemConfig,
  makeWrapper,
  puppet-bolt,
  testers,
}:

(bundlerApp {
  pname = "bolt";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    # Set BOLT_GEM=1 to remove warning
    wrapProgram $out/bin/bolt --set BOLT_GEM 1
  '';

  exes = [ "bolt" ];

  gemConfig = defaultGemConfig // {
    bolt = attrs: {
      # scripts in libexec will be executed by remote host,
      # so shebangs should remain unchanged
      dontPatchShebangs = true;
    };
  };

  gemdir = ./.;

  passthru = {
    tests.version = testers.testVersion {
      version = (import ./gemset.nix).bolt.version;
      package = puppet-bolt;
    };

    updateScript = bundlerUpdateScript "puppet-bolt";
  };

  meta = {
    description = "Execute commands remotely over SSH and WinRM";
    homepage = "https://github.com/puppetlabs/bolt";
    changelog = "https://github.com/puppetlabs/bolt/blob/main/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      uvnikita
      anthonyroussel
    ];

    platforms = lib.platforms.unix;
    mainProgram = "bolt";
  };
}).overrideAttrs
  (old: {
    name = "puppet-bolt-${(import ./gemset.nix).bolt.version}";
  })
