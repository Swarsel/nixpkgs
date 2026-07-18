{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchNpmDeps,
  nix-update-script,
  nodejs,
  npmHooks,
  postgresql,
  postgresqlTestHook,
  versionCheckHook,
  defaultApiEndPoint ? "https://api.getdnote.com",
}:

buildGoModule rec {
  pname = "dnote";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "dnote";
    repo = "dnote";
    tag = "cli-v${version}";
    hash = "sha256-so86Pit8/JeO/qwoOCZp8gY/E/HwhiDi6nzye2AM33A=";
  };

  postPatch = ''
    # This is not used and compile error
    rm -rf pkg/e2e
  '';

  nativeBuildInputs = [
    npmHooks.npmConfigHook
    nodejs
  ];

  vendorHash = "sha256-PExF+1SWcCROmthzo1e8Y7zqhW780GufYe35l0FRhxY=";

  env = {
    DBHost = "localhost";
    DBName = "test_db";
    DBPassword = "";
    DBPort = "5432";
    DBSkipSSL = true;
    DBUser = "postgres";
    DisableRegistration = false;
    SmtpHost = "mock-SmtpHost";
    SmtpPassword = "mock-SmtpPassword";
    SmtpPort = 465;
    SmtpUsername = "mock-SmtpUsername";
    WebURL = "http://localhost:3000";
    postgresqlEnableTCP = true;
  };

  preBuild = ''
    patchShebangs .

    pushd pkg/server/assets

    ./styles/build.sh
    ./js/build.sh

    popd
  '';

  nativeCheckInputs = [
    postgresqlTestHook
    postgresql
  ];

  checkFlags = [ "-p 1" ];

  postInstall = ''
    mv $out/bin/cli $out/bin/dnote-cli
    mv $out/bin/server $out/bin/dnote-server
    mv $out/bin/schema $out/bin/dnote-schema
    mv $out/bin/watcher $out/bin/dnote-watcher
  '';

  # Fails on darwin:
  # panic: initializing context: initializing files: creating the dnote dir:
  #   initializing config dir: creating a directory at /var/empty/.config/dnote: mkdir /var/empty: file exists
  doInstallCheck = !stdenv.hostPlatform.isDarwin;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-X github.com/dnote/dnote/pkg/server/buildinfo.Version=${version}"
    "-X github.com/dnote/dnote/pkg/cli/buildinfo.Version=${version}"
    "-X main.apiEndpoint=${defaultApiEndPoint}"
    "-X main.versionTag=${version}"
    "-X github.com/dnote/dnote/pkg/server/buildinfo.Standalone=true"
    "-X github.com/dnote/dnote/pkg/server/buildinfo.JSFiles=main.js"
    "-X github.com/dnote/dnote/pkg/server/buildinfo.CSSFiles=main.css"
  ];

  npmDeps = fetchNpmDeps {
    inherit version src;
    pname = "${pname}-webui";
    hash = "sha256-yq55iO3Svqbjah9HdWfSicJISNEipxUkNDD1KJ7ZUhY=";
    sourceRoot = "${src.name}/pkg/server/assets";
  };

  npmRoot = "pkg/server/assets";

  overrideModAttrs = oldAttrs: {
    # Do not add `npmConfigHook` to `goModules`
    nativeBuildInputs = lib.remove npmHooks.npmConfigHook oldAttrs.nativeBuildInputs;
    preBuild = null;
  };

  tags = [
    "fts5"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/dnote-cli";
  versionCheckProgramArg = "version";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Simple command line notebook for programmers";
    homepage = "https://www.getdnote.com/";
    changelog = "https://github.com/dnote/dnote/blob/cli-v${version}/CHANGELOG.md";

    license = with lib.licenses; [
      gpl3Only
      agpl3Only
    ];

    maintainers = with lib.maintainers; [ bot-wxt1221 ];
    platforms = lib.platforms.unix;
  };
}
