{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  makeWrapper,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "happy-coder";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "slopus";
    repo = "happy-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WKzbpxHqE3Dxqy/PDj51tM9+Wl2Pallfrc5UU2MxNn8=";
  };

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    makeWrapper
  ];

  # Currently `happy` requires `node` to start its daemon
  postInstall = ''
    wrapProgram $out/bin/happy \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs
        ]
      }
    wrapProgram $out/bin/happy-mcp \
      --prefix PATH : ${
        lib.makeBinPath [
          nodejs
        ]
      }
  '';

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-3/qcbCJ+Iwc+9zPCHKsCv05QZHPUp0it+QR3z7m+ssw=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  meta = {
    description = "Mobile and web client wrapper for Claude Code and Codex with end-to-end encryption";
    homepage = "https://github.com/slopus/happy-cli";
    changelog = "https://github.com/slopus/happy-cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ onsails ];
    mainProgram = "happy";
  };
})
