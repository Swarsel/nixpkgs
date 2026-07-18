{
  lib,
  bundlerApp,
  bundlerUpdateScript,
}:

bundlerApp {
  pname = "coltrane";
  exes = [ "coltrane" ];
  gemdir = ./.;
  passthru.updateScript = bundlerUpdateScript "coltrane";

  meta = {
    description = "Music calculation library/CLI";

    longDescription = ''
      coltrane allows to search for Notes, Chords, Scales for
      guitar, bass, piano and ukelele
    '';

    homepage = "https://github.com/pedrozath/coltrane";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ panaeon ];
    mainProgram = "coltrane";
  };
}
