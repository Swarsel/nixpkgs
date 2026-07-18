{
  lib,
  stdenv,
  fetchFromGitHub,
  nixosTests,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "freescout";
  version = "1.8.229";

  src = fetchFromGitHub {
    owner = "freescout-help-desk";
    repo = "freescout";
    tag = finalAttrs.version;
    hash = "sha256-oA/GWEhdqmXt7v6iRKqud75uUBj1a6nKN7EjaYF0USk=";
  };

  patches = [
    ./0001-settings-catch-unwritable-.env.patch
  ];

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/freescout
    cp -ar . $out/share/freescout
    chmod +x $out/share/freescout/artisan

    runHook postInstall
  '';

  __structuredAttrs = true;
  # Because freescout is searching for some folders only relative to it's own source location, we need to have the symlinks to the actual locations in here
  dontCheckForBrokenSymlinks = true;

  prePatch = ''
    rm -rf storage
    rm bootstrap/cache/.gitignore
    rm public/{css,js}/builds/.htaccess
    rm {Modules,public/modules}/.gitkeep
    rmdir Modules public/modules bootstrap/cache public/{css,js}/builds
    ln -rs data/.env .env
    ln -rs data/storage storage
    ln -rs data/bootstrap/cache bootstrap/cache
    ln -rs data/storage/app/public public/storage
    ln -rs data/public/css/builds public/css/builds
    ln -rs data/public/js/builds public/js/builds
    ln -rs data/Modules Modules
    ln -rs data/public/modules public/modules
  '';

  preferLocalBuild = true;
  passthru.tests = lib.attrValues nixosTests.freescout;

  meta = with lib; {
    description = "Free self-hosted help desk & shared mailbox";
    homepage = "https://freescout.net/";
    changelog = "https://github.com/freescout-help-desk/freescout/releases/tag/${finalAttrs.src.tag}";
    license = licenses.agpl3Only;
    maintainers = with maintainers; [ e1mo ];
    platforms = platforms.all;
  };
})
