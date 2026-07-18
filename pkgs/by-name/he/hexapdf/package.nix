{
  lib,
  bundlerApp,
  bundlerUpdateScript,
  ruby,
}:

bundlerApp {
  inherit ruby;
  pname = "hexapdf";
  exes = [ "hexapdf" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "hexapdf";

  meta = {
    description = "Versatile PDF creation and manipulation library";
    homepage = "https://hexapdf.gettalong.org/";
    changelog = "https://github.com/gettalong/hexapdf/blob/master/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bbenno ];
    platforms = lib.platforms.unix;
    mainProgram = "hexapdf";
  };
}
