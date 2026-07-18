{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
  nix-update-script,
}:
let
  version = "0.0.61";
in
buildGoModule {

  inherit version;
  pname = "mcap-cli";

  src = fetchFromGitHub {
    owner = "foxglove";
    repo = "mcap";
    rev = "releases/mcap-cli/v${version}";
    hash = "sha256-PR0w/D5XwLaRP9vkRt8f9huG75lPTIwyhcegjlY1pno=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  vendorHash = "sha256-Q1TjUlS7+fV2HBQk108c+o/9IRpDc9C8jzBk048Mkig=";

  env = {
    CGO_ENABLED = "1";
    GOWORK = "off";
  };

  # copy the local versions of the workspace modules
  postConfigure = ''
    chmod -R u+w vendor
    rm -rf vendor/github.com/foxglove/mcap/go/{mcap,ros}
    cp -r ../../{mcap,ros} vendor/github.com/foxglove/mcap/go
  '';

  checkFlags = [
    # requires git-lfs and network
    # https://github.com/foxglove/mcap/issues/895
    "-skip=TestCat|TestInfo|TestRequiresDuplicatedSchemasForIndexedMessages|TestPassesIndexedMessagesWithRepeatedSchemas|TestSortFile"
  ];

  postInstall = lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) (
    let
      emulator = stdenv.hostPlatform.emulator buildPackages;
    in
    ''
      installShellCompletion --cmd mcap \
        --bash <(${emulator} $out/bin/mcap completion bash) \
        --fish <(${emulator} $out/bin/mcap completion fish) \
        --zsh <(${emulator} $out/bin/mcap completion zsh)
    ''
  );

  ldflags = [ "-X github.com/foxglove/mcap/go/cli/mcap/cmd.Version=${version}" ];
  modRoot = "go/cli/mcap";

  tags = [
    "sqlite_omit_load_extension"
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    "netgo"
    "osusergo"
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "MCAP CLI tool to inspect and fix MCAP files";
    homepage = "https://github.com/foxglove/mcap";
    license = with lib.licenses; [ mit ];

    maintainers = with lib.maintainers; [
      therishidesai
    ];

    mainProgram = "mcap";
  };

}
