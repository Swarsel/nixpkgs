{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  ruby_3_4,
}:

(bundlerApp.override { ruby = ruby_3_4; }) {
  pname = "colorls";
  exes = [ "colorls" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "colorls";

  meta = {
    description = "Prettified LS";
    homepage = "https://github.com/athityakumar/colorls";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lukebfox
      nicknovitski
      cbley
    ];

    platforms = ruby_3_4.meta.platforms;
    mainProgram = "colorls";
  };
}
