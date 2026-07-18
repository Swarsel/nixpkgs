{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  nixosTests,
  nodejs,
  npmHooks,
}:

buildGoModule (finalAttrs: {
  pname = "karma";
  version = "0.125";

  src = fetchFromGitHub {
    owner = "prymitive";
    repo = "karma";
    rev = "v${finalAttrs.version}";
    hash = "sha256-/Iv7/CUwY/RlunXOd9H5xu4AzL/iXUEu+extyqinJ7M=";
  };

  postPatch = ''
    # Since we're using node2nix packages, the NODE_INSTALL hook isn't needed in the makefile
    sed -i \
      -e 's/$(NODE_INSTALL)//g' ./ui/Makefile \
      -e 's~NODE_PATH    := $(shell npm bin)~NODE_PATH    := ./node_modules~g' ./ui/Makefile \
      -e 's~NODE_MODULES := $(shell dirname `npm bin`)~NODE_MODULES := ./~g' ./ui/Makefile
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  vendorHash = "sha256-O+f8drIs+XOvLo8ifB/SHkBBxj0KPg2H1MAcCyJvLe4=";

  buildPhase = ''
    runHook preBuild

    VERSION="v${finalAttrs.version}" make -j$NIX_BUILD_CORES

    runHook postBuild
  '';

  installPhase = ''
    install -Dm 755 ./karma $out/bin/karma
  '';

  npmDeps = fetchNpmDeps {
    src = "${finalAttrs.src}/ui";
    hash = "sha256-wcQ6QWoRm+aQRf1L7xkmQIbYnfN+Fr/D0LeRlEK5nbE=";
  };

  npmRoot = "ui";

  overrideModAttrs = oldAttrs: {
    nativeBuildInputs = lib.filter (drv: drv != npmHooks.npmConfigHook) oldAttrs.nativeBuildInputs;
  };

  passthru.tests.karma = nixosTests.karma;

  meta = {
    description = "Alert dashboard for Prometheus Alertmanager";
    homepage = "https://karma-dashboard.io/";
    changelog = "https://github.com/prymitive/karma/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      nukaduka
      kraftnix
    ];

    mainProgram = "karma";
  };
})
