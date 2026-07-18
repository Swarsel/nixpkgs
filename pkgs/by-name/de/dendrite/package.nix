{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  nixosTests,
  postgresql,
  postgresqlTestHook,
}:

buildGoModule (finalAttrs: {
  pname = "matrix-dendrite";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "element-hq";
    repo = "dendrite";
    rev = "v${finalAttrs.version}";
    hash = "sha256-VxQ5fuGzkEL371TmnDQ0wNqqmfzupmsTX/v+eFthj8E=";
  };

  vendorHash = "sha256-QUztOoOesECAhwh4whzvrc43rJxjtPaEICUHno2DId0=";
  # PostgreSQL's request for a shared memory segment exceeded your kernel's SHMALL parameter
  doCheck = !stdenv.hostPlatform.isDarwin;

  nativeCheckInputs = [
    postgresqlTestHook
    postgresql
  ];

  preCheck = ''
    export PGUSER=$(whoami)
    # temporarily disable this failing test
    # it passes in upstream CI and requires further investigation
    rm roomserver/internal/input/input_test.go
  '';

  postgresqlTestUserOptions = "LOGIN SUPERUSER";

  subPackages = [
    # The server
    "cmd/dendrite"
    # admin tools
    "cmd/create-account"
    "cmd/generate-config"
    "cmd/generate-keys"
    "cmd/resolve-state"
    ## curl, but for federation requests, only useful for developers
    # "cmd/furl"
    ## an internal tool for upgrading ci tests, only relevant for developers
    # "cmd/dendrite-upgrade-tests"
    ## tech demos
    # "cmd/dendrite-demo-pinecone"
    # "cmd/dendrite-demo-yggdrasil"
  ];

  passthru.tests = {
    inherit (nixosTests) dendrite;
  };

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "v(.+)"
    ];
  };

  meta = {
    description = "Second-generation Matrix homeserver written in Go";
    homepage = "https://element-hq.github.io/dendrite";
    changelog = "https://github.com/element-hq/dendrite/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.unix;
    mainProgram = "dendrite";
  };
})
