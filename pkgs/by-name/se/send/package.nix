{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  makeBinaryWrapper,
  nix-update-script,
  nixosTests,
  nodejs_22,
}:
buildNpmPackage (finalAttrs: {
  pname = "send";
  version = "3.4.27";

  src = fetchFromGitHub {
    owner = "timvisee";
    repo = "send";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tfntox8Sw3xzlCOJgY/LThThm+mptYY5BquYDjzHonQ=";
  };

  nativeBuildInputs = [
    makeBinaryWrapper
  ];

  npmDepsHash = "sha256-QInXcYpZcAOJMS6QFtIapftyWsqA80ef+OiKJ9XEs98=";

  env = {
    NODE_OPTIONS = "--openssl-legacy-provider";
    PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = "true";
  };

  # @dannycoates/express-ws uses the unmaintained esm loader, which fails on nodejs_22.
  postConfigure = ''
    patch -p1 \
      --directory=node_modules/@dannycoates \
      < ${./dannycoates-express-ws-drop-esm-loader.patch}
  '';

  postInstall = ''
    cp -r dist $out/lib/node_modules/send/
    ln -s $out/lib/node_modules/send/dist/version.json $out/lib/node_modules/send/version.json

    makeWrapper ${lib.getExe finalAttrs.nodejs} $out/bin/send \
      --add-flags $out/lib/node_modules/send/server/bin/prod.js \
      --set "NODE_ENV" "production"
  '';

  nodejs = nodejs_22;
  npmDepsFetcherVersion = 2;
  npmPackFlags = [ "--ignore-scripts" ];

  passthru = {
    tests = {
      inherit (nixosTests) send;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "File Sharing Experiment";
    homepage = "https://github.com/timvisee/send";
    changelog = "https://github.com/timvisee/send/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      moraxyc
      MrSom3body
    ];

    mainProgram = "send";
  };
})
