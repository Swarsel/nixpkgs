{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "oh-my-posh";
  version = "29.26.1";

  src = fetchFromGitHub {
    owner = "jandedobbeleer";
    repo = "oh-my-posh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hE3L7emTk7MxzBUqSUDNKYiA2H1w9mcGhPYiR1OhYxg=";
  };

  postPatch = ''
    # these tests requires internet access
    rm cli/image/image_test.go config/migrate_glyphs_test.go cli/upgrade/notice_test.go segments/upgrade_test.go
  '';

  vendorHash = "sha256-6DX/x9uWUbwXy9ccB6NIVRKsOc1nJXtctItONAI7zPQ=";

  postInstall = ''
    mv $out/bin/{src,oh-my-posh}
    mkdir -p $out/share/oh-my-posh
    cp -r $src/themes $out/share/oh-my-posh/
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/jandedobbeleer/oh-my-posh/src/build.Version=${finalAttrs.version}"
    "-X github.com/jandedobbeleer/oh-my-posh/src/build.Date=1970-01-01T00:00:00Z"
  ];

  sourceRoot = "${finalAttrs.src.name}/src";

  tags = [
    "netgo"
    "osusergo"
    "static_build"
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Prompt theme engine for any shell";
    homepage = "https://ohmyposh.dev";
    changelog = "https://github.com/JanDeDobbeleer/oh-my-posh/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      lucperkins
      olillin
    ];

    mainProgram = "oh-my-posh";
  };
})
