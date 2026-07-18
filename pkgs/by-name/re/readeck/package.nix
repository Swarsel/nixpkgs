{
  lib,
  buildGoModule,
  fetchFromCodeberg,
  fetchNpmDeps,
  nix-update-script,
  nodejs_22,
  npmHooks,
  python3,
}:

buildGoModule (finalAttrs: {
  pname = "readeck";
  version = "0.22.3";

  src = fetchFromCodeberg {
    owner = "readeck";
    repo = "readeck";
    tag = finalAttrs.version;
    hash = "sha256-F4aj+vgCmwCnSBNa72kgCINNtmS6Zk1oeILZVXF5G+Y=";
  };

  nativeBuildInputs = [
    nodejs_22
    npmHooks.npmConfigHook
    (python3.withPackages (ps: with ps; [ babel ]))
  ];

  vendorHash = "sha256-cfd52pO2uUT5fdqCXM2rreXztb63FzUWv0s5/wbKXDw=";
  env.NODE_PATH = "$npmDeps";

  preBuild = ''
    make generate
  '';

  ldflags = [
    "-X"
    "codeberg.org/readeck/readeck/configs.version=${finalAttrs.version}"
    "-X"
    "codeberg.org/readeck/readeck/configs.buildTimeStr=1970-01-01T08:00:00Z"
  ];

  npmDeps = fetchNpmDeps {
    src = "${finalAttrs.src}/web";
    hash = "sha256-ysDEkoL0e84udmCmvfTMA5lWS08aSyyTuCq+/8s3FMw=";
  };

  npmRoot = "web";

  overrideModAttrs = oldAttrs: {
    # Do not add `npmConfigHook` to `goModules`
    nativeBuildInputs = lib.remove npmHooks.npmConfigHook oldAttrs.nativeBuildInputs;
    # Do not run `preBuild` when building `goModules`
    preBuild = null;
  };

  subPackages = [ "." ];

  tags = [
    "netgo"
    "osusergo"
    "sqlite_omit_load_extension"
    "sqlite_foreign_keys"
    "sqlite_json1"
    "sqlite_fts5"
    "sqlite_secure_delete"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Web application that lets you save the readable content of web pages you want to keep forever";
    homepage = "https://readeck.org/";
    changelog = "https://codeberg.org/readeck/readeck/releases/tag/${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      julienmalka
      linsui
    ];

    mainProgram = "readeck";
  };
})
