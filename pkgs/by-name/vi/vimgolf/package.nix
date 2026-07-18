{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "vimgolf";
  exes = [ "vimgolf" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "vimgolf";

  meta = {
    description = "Game that tests Vim efficiency";
    homepage = "https://vimgolf.com";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ leungbk ];
    platforms = lib.platforms.unix;
  };
}
