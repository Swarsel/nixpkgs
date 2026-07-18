{
  hash,
  npmDepsHash,
  vendorHash,
  version,
  lts ? false,
  nixUpdateExtraArgs ? [ ],
  rev ? "refs/tags/v${version}",
}:

{
  lib,
  stdenv,
  bash,
  brotli,
  buildGoModule,
  buildNpmPackage,
  fetchFromCodeberg,
  fetchpatch,
  forgejo,
  git,
  gzip,
  lndir,
  makeWrapper,
  nix-update-script,
  nixosTests,
  openssh,
  runCommand,
  writableTmpDirAsHomeHook,
  sqliteSupport ? true,
}:

let
  src = fetchFromCodeberg {
    inherit rev hash;
    owner = "forgejo";
    repo = "forgejo";
  };

  frontend = buildNpmPackage {
    inherit src version npmDepsHash;
    pname = "forgejo-frontend";

    buildPhase = ''
      ./node_modules/.bin/webpack
    '';

    # override npmInstallHook
    installPhase = ''
      mkdir $out
      cp -R ./public $out/
    '';
  };
in
buildGoModule rec {
  inherit
    version
    src
    vendorHash
    ;

  pname = "forgejo" + lib.optionalString lts "-lts";

  outputs = [
    "out"
    "data"
  ];

  patches = [
    ./static-root-path.patch
  ];

  postPatch = ''
    substituteInPlace modules/setting/server.go --subst-var data
  '';

  nativeBuildInputs = [
    makeWrapper
  ];

  preConfigure = ''
    export ldflags+=" -X main.ForgejoVersion=$(GITEA_VERSION=${version} make show-version-api)"
  '';

  nativeCheckInputs = [
    git
    openssh
    writableTmpDirAsHomeHook
  ];

  checkFlags =
    let
      skippedTests = [
        "TestPassword" # requires network: api.pwnedpasswords.com
        "TestCaptcha" # requires network: hcaptcha.com
        "TestDNSUpdate" # requires network: release.forgejo.org
        "TestMigrateWhiteBlocklist" # requires network: gitlab.com (DNS)
        "TestURLAllowedSSH/Pushmirror_URL" # requires network git.gay (DNS)
        "TestBleveDeleteIssue" # Known Flake-y https://github.com/NixOS/nixpkgs/issues/509878
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  # expose and use the GO_TEST_PACKAGES var from the Makefile
  # instead of manually copying over the entire list:
  # https://codeberg.org/forgejo/forgejo/src/tag/v11.0.6/Makefile#L128
  # https://codeberg.org/forgejo/forgejo/src/tag/v13.0.0/Makefile#L290
  preCheck = ''
    echo -e 'show-backend-tests: | compute-go-test-packages\n\t@echo ''${GO_TEST_PACKAGES}' >> Makefile
    getGoDirs() {
      make show-backend-tests
    }

    # TestRunHookPrePostReceive (cmd/hook_test.go) needs .git to pass
    git init
  '';

  preInstall = ''
    mv "$GOPATH/bin/forgejo.org" "$GOPATH/bin/forgejo"
  '';

  postInstall = ''
    mkdir $data
    cp -R ./{templates,options} ${frontend}/public $data
    mkdir -p $out
    cp -R ./options/locale $out/locale
    wrapProgram $out/bin/forgejo \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          git
          gzip
          openssh
        ]
      }
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
    "-X 'main.Tags=${lib.concatStringsSep " " tags}'"
  ];

  # $data is not available in goModules.drv
  overrideModAttrs = (
    _: {
      postPatch = null;
    }
  );

  subPackages = [
    "."
    "contrib/environment-to-ini"
  ];

  tags = lib.optionals sqliteSupport [
    "sqlite"
    "sqlite_unlock_notify"
  ];

  passthru = {
    # allow nix-update to handle npmDepsHash
    inherit (frontend) npmDeps;

    data-compressed =
      runCommand "forgejo-data-compressed"
        {
          nativeBuildInputs = [
            brotli
            lndir
          ];
        }
        ''
          mkdir $out
          lndir ${forgejo.data}/ $out/

          # Create static gzip and brotli files
          find -L $out -type f -regextype posix-extended -iregex '.*\.(css|html|js|svg|ttf|txt)' \
            -exec gzip --best --keep --force {} ';' \
            -exec brotli --best --keep --no-copy-stat {} ';'
        '';

    tests = if lts then nixosTests.forgejo-lts else nixosTests.forgejo;

    updateScript = nix-update-script {
      extraArgs = nixUpdateExtraArgs ++ [
        "--version-regex"
        "v(${lib.versions.major version}\\.[0-9.]+)"
      ];
    };
  };

  meta = {
    description = "Self-hosted lightweight software forge";
    homepage = "https://forgejo.org";
    changelog = "https://codeberg.org/forgejo/forgejo/releases/tag/v${version}";
    license = lib.licenses.gpl3Plus;
    mainProgram = "forgejo";
    broken = stdenv.hostPlatform.isDarwin;
    teams = [ lib.teams.forgejo ];
  };
}
