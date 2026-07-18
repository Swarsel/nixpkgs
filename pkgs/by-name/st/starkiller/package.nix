{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nix-update-script,
  nodejs_24,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "starkiller";
  version = "3.5.0";

  src = fetchFromGitHub {
    owner = "bc-security";
    repo = "starkiller";
    rev = "v${finalAttrs.version}";
    hash = "sha256-uFSv/SfXATi01e4VH6iImvRnlFTUB3OarhfSTLQDg/M=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    # Needed for executing package.json scripts
    nodejs_24
  ];

  buildPhase = ''
    runHook preBuild

    # Copying the workaround from
    # https://github.com/NixOS/nixpkgs/pull/386706
    pushd node_modules/vue-demi
    yarn run postinstall
    popd

    yarn --offline build

    runHook postBuild
  '';

  postInstall = ''
    mkdir $out
    cp -r dist/** $out
  '';

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-NAnROD2Bt2sYydLbZVzudwDajbc4zonTjSLcdD32KNE=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Web UI for Empire";
    homepage = "https://github.com/BC-SECURITY/Starkiller";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fzakaria
      vrose
    ];

    platforms = lib.platforms.unix;
  };
})
