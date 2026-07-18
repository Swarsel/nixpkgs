{
  lib,
  stdenv,
  cctools,
  fetchFromGitea,
  libsass,
  nix-update-script,
  nodejs,
  pkg-config,
  python311,
  xcbuild,
  yarn-berry_3,
}:

let
  yarn-berry = yarn-berry_3;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "admin-fe";
  version = "2.3.0-2-unstable-2025-12-07";

  src = fetchFromGitea {
    owner = "AkkomaGang";
    repo = "admin-fe";
    rev = "a0e3b95a75367d1b5e329963a3d54f67cf59dfca";
    hash = "sha256-eEAM1itUvpR57B0BseeeRuV+ZjcYiJvbdln8vleRNcc=";
    domain = "akkoma.dev";
    # upstream repository archive fetching is broken
    forceFetchGit = true;
  };

  nativeBuildInputs = [
    yarn-berry.yarnBerryConfigHook
    yarn-berry
    nodejs
    pkg-config
    python311
    libsass
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xcbuild
    cctools.libtool
  ];

  buildPhase = ''
    runHook preBuild
    yarn run build:prod --offline
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -R -v dist $out
    runHook postInstall
  '';

  offlineCache = yarn-berry.fetchYarnBerryDeps {
    hash = "sha256-YZlvIr27bHBgsQcBiayqEX07kjX6iH2Kh5wt+PQFq04=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version=branch=stable" ];
  };

  meta = {
    description = "Admin interface for Akkoma";
    homepage = "https://akkoma.dev/AkkomaGang/akkoma-fe/";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ mvs ];
  };
})
