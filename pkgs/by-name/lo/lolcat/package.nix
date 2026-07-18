{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  ruby_3_4,
}:

(bundlerApp.override { ruby = ruby_3_4; }) {
  pname = "lolcat";
  exes = [ "lolcat" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "lolcat";

  meta = {
    description = "Rainbow version of cat";
    homepage = "https://github.com/busyloop/lolcat";
    license = lib.licenses.bsd3;

    maintainers = [
      lib.maintainers.StillerHarpo
      lib.maintainers.nicknovitski
    ];

    mainProgram = "lolcat";
  };
}
