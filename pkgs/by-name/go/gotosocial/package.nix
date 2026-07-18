{
  lib,
  buildGo125Module,
  fetchFromCodeberg,
  fetchYarnDeps,
  nix-update-script,
  nixosTests,
  nodejs,
  yarn,
  yarnConfigHook,
}:
buildGo125Module (finalAttrs: {
  pname = "gotosocial";
  version = "0.22.0";

  src = fetchFromCodeberg {
    owner = "superseriousbusiness";
    repo = "gotosocial";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rslzi9WqPqN/wm9PN6SWdXtLdMRJJV6Hhb3whJ0RicU=";
  };

  nativeBuildInputs = [
    nodejs
    yarn
    yarnConfigHook
  ];

  vendorHash = null;

  postConfigure = ''
    pushd ./web/source
    runHook yarnConfigHook
    popd
  '';

  # preparing assets
  # https://codeberg.org/superseriousbusiness/gotosocial/src/branch/main/.goreleaser.yml#L12
  preBuild = ''
    go run ./vendor/github.com/go-swagger/go-swagger/cmd/swagger generate spec --scan-models --exclude-deps -o web/assets/swagger.yaml
    substituteInPlace web/assets/swagger.yaml --replace-fail "REPLACE_ME" "${finalAttrs.version}"
    yarn --offline --cwd ./web/source ts-patch install
    yarn --offline --cwd ./web/source build
    ./scripts/bundle_licenses.sh
  '';

  # tests are working only on x86_64-linux
  # doCheck = stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64;
  # checks are currently very unstable in our setup, so we should test manually for now
  doCheck = false;

  checkFlags =
    let
      # flaky / broken tests
      skippedTests = [
        # See: https://github.com/superseriousbusiness/gotosocial/issues/2651
        "TestPage/minID,_maxID_and_limit_set"
      ];
    in
    [ "-skip=^${builtins.concatStringsSep "$|^" skippedTests}$" ];

  postInstall = ''
    # remove a Go codegen helper binary
    rm $out/bin/gen

    mkdir -p $out/share/gotosocial/web
    mv web/{assets,template} $out/share/gotosocial/web
  '';

  # manually calling yarnConfigHook in sub-directory
  dontYarnInstallDeps = true;

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${finalAttrs.version}"
  ];

  tags = [
    "kvformat"
  ];

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-rfZxslIEoOTufENIvk8Eq5wzdD3rUpUP3wrMjmLH44k=";
    yarnLock = "${finalAttrs.src}/web/source/yarn.lock";
  };

  passthru.tests.gotosocial = nixosTests.gotosocial;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Fast, fun, ActivityPub server, powered by Go";

    longDescription = ''
      ActivityPub social network server, written in Golang.
      You can keep in touch with your friends, post, read, and
      share images and articles. All without being tracked or
      advertised to! A light-weight alternative to Mastodon
      and Pleroma, with support for clients!
    '';

    homepage = "https://gotosocial.org";
    changelog = "https://codeberg.org/superseriousbusiness/gotosocial/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      blakesmith
      cherrykitten
    ];
  };
})
