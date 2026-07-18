{
  lib,
  fetchFromGitHub,
  buildGo126Module,
  fetchPnpmDeps,
  nix-update-script,
  nixosTests,
  nodejs,
  pnpmConfigHook,
  pnpm_11,
  stdenvNoCC,
  typescript,
  versionCheckHook,
}:
buildGo126Module (finalAttrs: {
  pname = "qui";
  version = "1.22.0";

  src = fetchFromGitHub {
    owner = "autobrr";
    repo = "qui";
    tag = "v${finalAttrs.version}";
    hash = "sha256-psIkTzayXgK7OKEjRz8NJfQVVH6Xn5qp1GdRlEEPaxw=";
  };

  vendorHash = "sha256-n+CCRQk46j/ljAfFap3mgwxs4JF9Qr/TLqZILghgbU4=";

  preBuild = ''
    cp -r ${finalAttrs.qui-web}/* web/dist
  '';

  # some season-pack tests use non-existent source paths (e.g. /media/...) and
  # assert on a same-filesystem check that resolves them up to /. go's
  # t.TempDir honours $TMPDIR, which defaults to /build. so just point it to
  # something sane
  preCheck = ''
    export TMPDIR=/tmp
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  # Required for tests on Darwin
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-X github.com/autobrr/qui/internal/buildinfo.Version=${finalAttrs.version}"
    "-X main.PolarOrgID="
  ];

  qui-web = stdenvNoCC.mkDerivation (finalAttrs': {
    inherit (finalAttrs) src version;
    pname = "${finalAttrs.pname}-web";

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm_11
      typescript
    ];

    postBuild = ''
      pnpm run build
    '';

    installPhase = ''
      cp -r dist $out
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs')
        pname
        version
        src
        sourceRoot
        ;

      fetcherVersion = 4;
      hash = "sha256-53bj1QlfihIyKsQK5o3FsA9qWZJrNPWEJ441UK9nWR0=";
      pnpm = pnpm_11;
    };

    sourceRoot = "${finalAttrs.src.name}/web";
  });

  versionCheckProgramArg = "version";

  passthru = {
    tests.testService = nixosTests.qui;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "qui-web"
      ];
    };
  };

  meta = {
    description = "Modern alternative webUI for qBittorrent, with multi-instance support";
    homepage = "https://github.com/autobrr/qui";
    changelog = "https://github.com/autobrr/qui/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;

    maintainers = with lib.maintainers; [
      pta2002
      tmarkus
    ];

    platforms = lib.platforms.unix;
    mainProgram = "qui";
  };
})
