{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  ffmpeg,
  nix-update-script,
  nodejs,
  npmHooks,
}:
buildGoModule (finalAttrs: {
  pname = "seanime";
  version = "3.9.1";

  src = fetchFromGitHub {
    owner = "5rahim";
    repo = "seanime";
    tag = "v${finalAttrs.version}";
    hash = "sha256-T4TLQ3wMvUFURu5rDfUDWfnhSsmYWq4GGQBZvAd2ivs=";
  };

  patches = [ ./default-disable-update-check.patch ];

  nativeBuildInputs = [
    nodejs
    npmHooks.npmConfigHook
  ];

  vendorHash = "sha256-eTKLiwyB3bUIUlwLck8NG6oRdYaJioNs4AiSSPjADyg=";

  env = {
    npmDeps = fetchNpmDeps {
      src = "${finalAttrs.src}/seanime-web";
      hash = "sha256-mODqMuU1AtlNjLr9+OpORyXIyt7yMhIBJZTLDSj4fLQ=";
    };

    npmRoot = "seanime-web";
  };

  preBuild = ''
    npm run build --prefix seanime-web
    cp -r seanime-web/out web

    # .github scripts redeclare main
    rm -rf .github
  '';

  doCheck = false; # broken in clean environments

  ldflags = [
    "-s"
    "-w"
  ];

  # for transcoding
  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        ffmpeg
      ]
    }"
  ];

  subPackages = [ "." ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Open-source media server for anime and manga";
    homepage = "https://seanime.app";
    changelog = "https://github.com/5rahim/seanime/blob/main/CHANGELOG.md";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ thegu5 ];
    mainProgram = "seanime";
  };
})
