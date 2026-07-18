{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
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

let
  pname = "autobrr";
  version = "1.81.0";
  src = fetchFromGitHub {
    owner = "autobrr";
    repo = "autobrr";
    tag = "v${version}";
    hash = "sha256-Xm5cYtQabHkoiVZ6v71qWKIpx44obzr0Om2hahFUyO8=";
  };

  autobrr-web = stdenvNoCC.mkDerivation {
    inherit src version;
    pname = "${pname}-web";

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
      inherit (autobrr-web)
        pname
        version
        src
        sourceRoot
        ;

      fetcherVersion = 4;
      hash = "sha256-VDW1B8OVFZ72nBl8IYM5nXqit2za1Q8mXI6UhcmEeSo=";
      pnpm = pnpm_11;
    };

    sourceRoot = "${src.name}/web";
  };
in
buildGoModule (finalAttrs: {
  inherit
    pname
    version
    src
    ;

  vendorHash = "sha256-mOsiQXuhhNSbViEFecmlNk549LyfUIuc8FxwDma9XNI=";

  preBuild = ''
    cp -r ${finalAttrs.passthru.autobrr-web}/* web/dist
  '';

  # In darwin, tests try to access /etc/protocols, which is not permitted.
  doCheck = !stdenv.hostPlatform.isDarwin;
  doInstallCheck = !stdenv.hostPlatform.isDarwin;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  ldflags = [
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${src.tag}"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/autobrrctl";
  versionCheckProgramArg = "version";

  passthru = {
    inherit autobrr-web;
    tests.testService = nixosTests.autobrr;

    updateScript = nix-update-script {
      extraArgs = [
        "--subpackage"
        "autobrr-web"
      ];
    };
  };

  meta = {
    description = "Modern, easy to use download automation for torrents and usenet";
    homepage = "https://autobrr.com/";
    changelog = "https://autobrr.com/release-notes/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ av-gal ];
    platforms = with lib.platforms; darwin ++ freebsd ++ linux;
    mainProgram = "autobrr";
  };
})
