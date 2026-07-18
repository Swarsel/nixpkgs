{
  lib,
  bundlerApp,
  curl,
  makeWrapper,
}:

bundlerApp {
  pname = "wpscan";
  nativeBuildInputs = [ makeWrapper ];

  postBuild = ''
    wrapProgram "$out/bin/wpscan" \
      --prefix PATH : ${lib.makeBinPath [ curl ]}
  '';

  exes = [ "wpscan" ];
  gemdir = ./.;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Black box WordPress vulnerability scanner";
    homepage = "https://wpscan.org/";
    changelog = "https://github.com/wpscanteam/wpscan/releases";
    license = lib.licenses.unfreeRedistributable;

    maintainers = with lib.maintainers; [
      nyanloutre
    ];

    platforms = lib.platforms.unix;
  };
}
