{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nixosTests,
  nodejs,
  php,
  yarn,
  yarnConfigHook,
}:

php.buildComposerProject2 (finalAttrs: {
  inherit php;
  pname = "engelsystem";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "engelsystem";
    repo = "engelsystem";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hnTkeSqxkvO2Prop0VaBAV/4opr46wjEaJ5ptd5zQ34=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    nodejs
    yarn
    yarnConfigHook
  ];

  vendorHash = "sha256-oGpgtkX0UVSdVceQ8pD3PuGBITifQzaMIb4QRdc7WeY=";

  preBuild = ''
    yarn build
  '';

  preInstall = ''
    rm -rf node_modules

    # link config and storage into FHS locations
    ln -sf /etc/engelsystem/config.php ./config/config.php
    rm -rf storage
    ln -snf /var/lib/engelsystem/storage/ ./storage
  '';

  postInstall = ''
    mkdir $out/bin
    ln -s $out/share/php/engelsystem/bin/migrate $out/bin/migrate
  '';

  composerNoDev = true;
  composerStrictValidation = false;

  yarnOfflineCache = fetchYarnDeps {
    pname = "${finalAttrs.pname}-yarn-deps";
    hash = "sha256-IMg1AoqCiQEvMHeqXgonIY2J0nmBHLW2Drz/Vb0rD48=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.tests = nixosTests.engelsystem;

  meta = {
    description = "Coordinate your volunteers in teams, assign them to work shifts or let them decide for themselves when and where they want to help with what";
    homepage = "https://engelsystem.de";
    changelog = "https://github.com/engelsystem/engelsystem/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ tmarkus ];
    platforms = lib.platforms.all;
    mainProgram = "migrate";
  };
})
