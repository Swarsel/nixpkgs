{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  findutils,
  makeBinaryWrapper,
  nix-update-script,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gatsby-cli";
  version = "5.16.0";

  src = fetchFromGitHub {
    owner = "gatsbyjs";
    repo = "gatsby";
    tag = "gatsby-cli@${finalAttrs.version}";
    hash = "sha256-OK2GqO7UMYR7EFU4UC1cHtKfsQAMJP7KuUaQCUfyTBE=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    # Needed for executing package.json scripts
    nodejs
    findutils
    makeBinaryWrapper
  ];

  preBuild = ''
    patchShebangs packages/**/node_modules
    yarn run lerna run prepare --scope gatsby-cli --include-dependencies
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/node_modules/
    mv packages/ $out/lib/packages/
    mv node_modules/* $out/lib/node_modules/

    makeWrapper ${lib.getExe nodejs} $out/bin/gatsby \
      --add-flags $out/lib/packages/gatsby-cli/cli.js \
      --set NODE_PATH $out/lib/node_modules

    runHook postInstall
  '';

  yarnBuildFlags = [
    "run"
    "build"
    "--scope"
    "gatsby-cli"
    "--include-dependencies"
  ];

  yarnBuildScript = "lerna";
  yarnKeepDevDeps = true;

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-tmMPz/GunOMMGAHP2/nQkDBeZ+LtCdqQA/Bc6PFzOdk=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      # Fixes an error with having too many versions available
      "--use-github-releases"
      "--version-regex"
      "gatsby@(.*)"
    ];
  };

  meta = {
    description = "The Gatsby command line interface";
    homepage = "https://github.com/gatsbyjs/gatsby/tree/master/packages/gatsby-cli#readme";
    changelog = "https://github.com/gatsbyjs/gatsby/releases/tag/gatsby%2540${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "gatsby";
  };
})
