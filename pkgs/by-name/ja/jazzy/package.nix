{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "jazzy";
  exes = [ "jazzy" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "jazzy";

  meta = {
    description = "Command-line utility that generates documentation for Swift or Objective-C";
    homepage = "https://github.com/realm/jazzy";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      nicknovitski
    ];

    platforms = lib.platforms.darwin;
  };
}
