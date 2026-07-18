{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  openvox,
  ruby_3_4,
  testers,
}:
((bundlerApp.override { ruby = ruby_3_4; }) {
  pname = "openvox";
  exes = [ "puppet" ];
  gemdir = ./.;

  passthru = {
    tests.version = testers.testVersion {
      inherit ((import ./gemset.nix).openvox) version;
      command = "HOME=$(mktemp -d) puppet --version";
      package = openvox;
    };

    updateScript = bundlerUpdateScript "openvox";
  };

  meta = {
    description = "Server automation framework and application";
    homepage = "https://github.com/OpenVoxProject/openvox";
    changelog = "https://github.com/OpenVoxProject/openvox/blob/main/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ skyethepinkcat ];
    mainProgram = "puppet";
  };
}).overrideAttrs
  # Workaround `bundlerApp` not specifying `__structuredAttrs = true` and `strictDeps = true` for its result package.
  {
    # TODO(@ShamrockLee, @skyethepinkcat): Revert/remove after PR #540069 lands on the master branch.
    strictDeps = true;
    # TODO(@ShamrockLee, @skyethepinkcat): Revert/remove after PR #539303 lands on the master branch.
    __structuredAttrs = true;
  }
