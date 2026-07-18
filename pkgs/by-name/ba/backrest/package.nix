{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  _experimental-update-script-combinators,
  buildGoModule,
  fetchPnpmDeps,
  gzip,
  iana-etc,
  libredirect,
  makeBinaryWrapper,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
  restic,
  util-linux,
  versionCheckHook,
}:
let
  pnpm = pnpm_11;

  pname = "backrest";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "garethgeorge";
    repo = "backrest";
    tag = "v${version}";
    hash = "sha256-RxjPjvnKy8UM1OXRklJF/HSZ6FMiHWYQBsZ6owMJMF0=";
    leaveDotGit = true;

    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  # we need to pin the inlang plugins to specific versions because
  # the remote ones are not pinned and we can't fetch them in the sandbox.
  inlang-plugins = lib.mapAttrs (remote: info: fetchurl { inherit (info) url hash; }) (
    lib.importJSON ./inlang-plugins.json
  );

  frontend = stdenv.mkDerivation (finalAttrs: {
    inherit version src;
    pname = "backrest-webui";

    postPatch = ''
      # Replace remote inlang plugins with local ones
      ${lib.concatStringsSep "\n" (
        lib.mapAttrsToList (remote: local: ''
          substituteInPlace project.inlang/settings.json \
            --replace-fail "${remote}" "${local}"
        '') inlang-plugins
      )}
    '';

    strictDeps = true;

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm
    ];

    buildPhase = ''
      runHook preBuild
      export BACKREST_BUILD_VERSION=${version}
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mv dist $out
      runHook postInstall
    '';

    __structuredAttrs = true;

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-y6NYFPepibiTuvPMwyc5cN3TwAc2W7RtPbCmzWDozNQ=";
      sourceRoot = "${finalAttrs.src.name}/webui";
    };

    sourceRoot = "${finalAttrs.src.name}/webui";
  });
in
buildGoModule (finalAttrs: {
  inherit
    pname
    src
    version
    ;

  patches = [
    # https://github.com/garethgeorge/backrest/pull/1293
    ./0001-fix-rm-deprecated-import-github.com-ncruces-go-sqlit.patch
    # https://github.com/garethgeorge/backrest/pull/1294
    ./0002-fix-exit-after-printing-version.patch
    # https://github.com/garethgeorge/backrest/pull/1295
    ./0003-fix-quit-tray-on-graceful-shutdown.patch
  ];

  postPatch = ''
    sed -i -e \
      '/func installRestic(targetPath string) error {/a\
        return fmt.Errorf("installing restic from an external source is prohibited by nixpkgs")' \
      internal/resticinstaller/resticinstaller.go
  '';

  strictDeps = true;

  nativeBuildInputs = [
    gzip
    makeBinaryWrapper
  ];

  vendorHash = "sha256-yadRulgtcDPthWLeTydcMol/vwriflKvDu7zgoehZCM=";

  preBuild = ''
    ldflags+=" -X main.commit=$(cat COMMIT)"

    mkdir -p ./webui/dist
    cp -r ${finalAttrs.passthru.frontend}/* ./webui/dist

    go generate -skip="npm" ./...
  '';

  doCheck = true;

  nativeCheckInputs = [
    util-linux
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ libredirect.hook ];

  checkFlags =
    let
      skippedTests = [
        "TestMultihostIndexSnapshots"
        "TestRunCommand"
        "TestSnapshot"
      ]
      ++ lib.optionals stdenv.hostPlatform.isDarwin [
        "TestBackup" # relies on ionice
        "TestCancelBackup"
        "TestFirstRun" # e2e test requires networking
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  # Use restic from nixpkgs, otherwise download fails in sandbox
  preCheck = ''
    export BACKREST_RESTIC_COMMAND="${lib.getExe restic}"
    export HOME=$(pwd)
  ''
  + lib.optionalString (stdenv.hostPlatform.isDarwin) ''
    export NIX_REDIRECTS=/etc/protocols=${iana-etc}/etc/protocols:/etc/services=${iana-etc}/etc/services
  '';

  postInstall = ''
    wrapProgram $out/bin/backrest \
      --set-default BACKREST_RESTIC_COMMAND "${lib.getExe restic}"
    makeBinaryWrapper $out/bin/backrest $out/bin/backrest-tray \
      --add-flags "-tray"
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "cmd/backrest" ];
  tags = [ "tray" ];
  versionCheckProgramArg = "-version";

  passthru = {
    inherit frontend inlang-plugins;

    updateScript = _experimental-update-script-combinators.sequence [
      (nix-update-script {
        extraArgs = [
          "--subpackage"
          "frontend"
        ];
      })
      ./update-inlang-plugins.sh
    ];
  };

  meta = {
    description = "Web UI and orchestrator for restic backup";
    homepage = "https://github.com/garethgeorge/backrest";
    changelog = "https://github.com/garethgeorge/backrest/releases/tag/${finalAttrs.src.rev}";
    license = lib.licenses.gpl3Only;

    maintainers = with lib.maintainers; [
      iedame
      alexandru0-dev
      phanirithvij
    ];

    platforms = lib.platforms.unix;
    mainProgram = "backrest";
  };
})
