{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs,
  runCommand,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "prettierd";
  version = "0.27.0";

  src = fetchFromGitHub {
    owner = "fsouza";
    repo = "prettierd";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8fy8ciPRd2ZRZ56vzz0quDNqpaAPfUFBN4fjVTdd2Cg=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  # launch the daemon with the same node version used to run the CLI
  # fixes "Error: spawn node ENOENT" if node isn't available on the user's path
  postInstall = ''
    wrapProgram $out/bin/prettierd \
      --prefix PATH : ${lib.makeBinPath [ nodejs ]}
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-PPi+nobxbVTC9G0Xwu5kcNH6zxtJXueYGuZkl3+XTIo=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru = {
    tests = lib.optionalAttrs (!stdenv.hostPlatform.isDarwin) {
      format =
        runCommand "prettierd-format-file-test" { nativeBuildInputs = [ finalAttrs.finalPackage ]; }
          ''
            export HOME=$(mktemp -d)
            prettierd ${finalAttrs.src}/package.json < ${finalAttrs.src}/package.json > $out
          '';
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Prettier, as a daemon, for improved formatting speed";
    homepage = "https://github.com/fsouza/prettierd";
    changelog = "https://github.com/fsouza/prettierd/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      NotAShelf
      n3oney
    ];

    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "prettierd";
  };
})
