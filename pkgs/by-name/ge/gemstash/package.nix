{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  nixosTests,
}:

bundlerApp {
  pname = "gemstash";
  exes = [ "gemstash" ];
  gemdir = ./.;

  passthru = {
    tests = { inherit (nixosTests) gemstash; };
    updateScript = bundlerUpdateScript "gemstash";
  };

  meta = {
    description = "Cache for RubyGems.org and a private gem server";
    homepage = "https://github.com/rubygems/gemstash";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      viraptor
    ];
  };
}
