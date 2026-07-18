{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  llvmPackages,
  nix-update-script,
  rustPlatform,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "iamb";
  version = "0.0.11";

  src = fetchFromGitHub {
    owner = "ulyssa";
    repo = "iamb";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nvEOtV1Y5K9E1Lj+bPnQ6k1AneDM9OT3RbV3Urm/1Qs=";
  };

  patches = [
    ./0001-increase-recursion-limit-to-fix-matrix-sdk-sqlite.patch
  ];

  nativeBuildInputs = [
    installShellFiles
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    # TODO: Remove once #536365 reaches this branch
    llvmPackages.lld
  ];

  cargoHash = "sha256-uWYNFNoCiqw6gYuHZWmZmZVs7lKNvhzjwEyxgcbvv+8=";

  env = lib.optionalAttrs stdenv.hostPlatform.isDarwin {
    # TODO: Remove once #536365 reaches this branch
    NIX_CFLAGS_LINK = "-fuse-ld=lld";
  };

  postInstall = ''
    installManPage $src/docs/iamb.{1,5}
    install -D $src/docs/iamb.svg -t $out/share/icons/hicolor/scalable/apps
    install -D $src/docs/iamb.metainfo.xml $out/share/appdata/chat.iamb.iamb.appdata.xml
    install -D $src/iamb.desktop -t $out/share/applications
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Matrix client for Vim addicts";
    homepage = "https://github.com/ulyssa/iamb";
    changelog = "https://github.com/ulyssa/iamb/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ meain ];
    mainProgram = "iamb";
  };
})
