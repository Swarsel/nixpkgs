{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  inspec,
  ruby_3_4, # fix "Source locally installed gems is ignoring ... because it is missing extensions"
  testers,
}:

bundlerApp {
  pname = "inspec";
  exes = [ "inspec" ];
  gemdir = ./.;
  ruby = ruby_3_4;

  passthru = {
    tests.version = testers.testVersion {
      inherit ((import ./gemset.nix).inspec) version;
      command = "inspec version";
      package = inspec;
    };

    updateScript = bundlerUpdateScript "inspec";
  };

  meta = {
    description = "Open-source testing framework for infrastructure with a human- and machine-readable language for specifying compliance, security and policy requirements";
    homepage = "https://inspec.io/";
    license = lib.licenses.unfree; # rubygems distribution is unfree, see https://github.com/inspec/inspec/blob/main/Chef-EULA
    maintainers = with lib.maintainers; [ dylanmtaylor ];
    mainProgram = "inspec";
  };
}
