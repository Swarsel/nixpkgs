{
  lib,
  stdenv,
  docker,
  fetchzip,
  kubectl,
  makeWrapper,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gefyra";
  version = "2.5.3";

  src = fetchzip {
    url = "https://github.com/gefyrahq/gefyra/releases/download/${finalAttrs.version}/gefyra-${finalAttrs.version}-linux-amd64.zip";
    hash = "sha256-0bSFeXvoLmlVwOfTEWpnXt3yHm7YwSoo5W9u4yPccHo=";
    stripRoot = false;
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    install -Dm755 gefyra "$out/bin/gefyra"
    runHook postInstall
  '';

  postInstall = ''
    wrapProgram $out/bin/gefyra \
      --prefix PATH : ${
        lib.makeBinPath [
          docker
          kubectl
        ]
      }
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Tool to connect local containers to kubernetes clusters";
    homepage = "https://gefyra.dev";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tobifroe ];
    platforms = lib.platforms.linux;
    mainProgram = "gefyra";
    downloadPage = "https://github.com/gefyrahq/gefyra";
  };
})
