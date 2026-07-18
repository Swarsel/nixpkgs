{
  lib,
  fetchFromGitHub,
  makeWrapper,
  pstree,
  stdenvNoCC,
  tt-smi,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tt-system-tools";
  version = "1.4.1";

  src = fetchFromGitHub {
    owner = "tenstorrent";
    repo = "tt-system-tools";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fqmMO6Zo61gO0HtKasSKTt7kC8YGr5crymwbqVNQLck=";
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 tt-oops/tt-oops.sh $out/bin/tt-oops
    wrapProgram "$out/bin/tt-oops" \
      --prefix PATH : ${
        lib.makeBinPath [
          tt-smi
          pstree
        ]
      }

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "System tools for Tenstorrent cards";
    homepage = "https://github.com/tenstorrent/tt-system-tools";
    changelog = "https://github.com/tenstorrent/tt-system-tools/blob/${finalAttrs.src.tag}/debian/changelog";
    license = with lib.licenses; [ asl20 ];
    maintainers = with lib.maintainers; [ RossComputerGuy ];
    platforms = lib.platforms.linux;
  };
})
