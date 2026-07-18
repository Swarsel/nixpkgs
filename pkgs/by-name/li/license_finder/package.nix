{
  lib,
  bundlerEnv,
  bundlerUpdateScript,
  ruby,
}:

bundlerEnv {
  inherit ruby;
  pname = "license_finder";
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "license_finder";

  meta = {
    description = "Find licenses for your project's dependencies";
    homepage = "https://github.com/pivotal/licensefinder";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
  };
}
