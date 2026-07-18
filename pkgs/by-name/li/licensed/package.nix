{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:
bundlerApp {
  pname = "licensed";
  exes = [ "licensed" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "licensed";

  meta = {
    description = "Ruby gem to cache and verify the licenses of dependencies";
    homepage = "https://github.com/github/licensed";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.jcaesar ];
    platforms = lib.platforms.linux;
  };
}
