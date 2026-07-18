{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  puppet-lint,
  testers,
}:

bundlerApp {
  pname = "puppet-lint";
  exes = [ "puppet-lint" ];
  gemdir = ./.;

  passthru = {
    tests.version = testers.testVersion {
      version = (import ./gemset.nix).puppet-lint.version;
      package = puppet-lint;
    };

    updateScript = bundlerUpdateScript "puppet-lint";
  };

  meta = {
    description = "Checks Puppet code against the recommended Puppet language style guide";
    homepage = "https://github.com/puppetlabs/puppet-lint";
    changelog = "https://github.com/puppetlabs/puppet-lint/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ anthonyroussel ];
    mainProgram = "puppet-lint";
  };
}
