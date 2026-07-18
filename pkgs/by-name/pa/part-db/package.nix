{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nixosTests,
  nodejs,
  php,
  yarnBuildHook,
  yarnConfigHook,
  cachePath ? "/var/cache/part-db/",
  envLocalPath ? "/var/lib/part-db/env.local",
  logPath ? "/var/log/part-db/",
  mediaPath ? "/var/lib/part-db/public/media/",
  uploadsPath ? "/var/lib/part-db/uploads/",
}:
let
  pname = "part-db";
  version = "2.13.1";

  srcWithVendor = php.buildComposerProject2 {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "Part-DB";
      repo = "Part-DB-server";
      tag = "v${version}";
      hash = "sha256-j7Kj03RxbrRoHJ4kFeZo1VmeHT3YucY4Zxog93+5Q38=";
    };

    vendorHash = "sha256-ZYo0gNsR9liMWWjHZGGf/XFNZJBnBrVVLf7WVhN/pY4=";

    postInstall = ''
      chmod -R u+w $out/share
      cd "$out"/share/php/part-db
      echo "Running composer dump-autoload to generate autoload_runtime.php..."
      composer dump-autoload --no-interaction
      export APP_ENV=prod
      export APP_SECRET=dummy
      export DATABASE_URL=sqlite:///%kernel.project_dir%/data/app.db
      php -d memory_limit=256M bin/console cache:warmup
      cd /build
      mv "$out"/share/php/part-db/* $out/
      mv "$out"/share/php/part-db/.* $out/
      rm -rf "$out/share"
    '';

    composerNoPlugins = false;
    # Upstream composer.json file is missing the description field
    composerStrictValidation = false;

    php = php.buildEnv {
      extensions = (
        { all, enabled }:
        enabled
        ++ (with all; [
          xsl
        ])
      );
    };
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit pname version;
  src = srcWithVendor;

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    nodejs
  ];

  installPhase = ''
    rm -r node_modules
    mkdir $out
    mv * .* $out/

    rm -rf $out/var/{cache,log} $out/public/media $out/uploads
    ln -s ${envLocalPath} $out/.env.local
    ln -s ${logPath} $out/var/log
    ln -s ${cachePath} $out/var/cache
    ln -s ${mediaPath} $out/public/media
    ln -s ${uploadsPath} $out/uploads
  '';

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-xdRMAOmGQFPuej/8A88edH23jL/3K8igx0BB7Z78sjM=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru.tests = { inherit (nixosTests) part-db; };

  meta = {
    description = "Open source inventory management system for your electronic components";
    homepage = "https://docs.part-db.de/";
    changelog = "https://github.com/Part-DB/Part-DB-server/releases/tag/v${version}";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      felbinger
      oddlama
    ];

    platforms = lib.platforms.linux;
  };
})
