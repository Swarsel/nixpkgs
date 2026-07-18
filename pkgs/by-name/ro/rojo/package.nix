{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rojo";
  version = "7.7.0";

  src = fetchFromGitHub {
    owner = "rojo-rbx";
    repo = "rojo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2atNAiv51MNpxXdwvKSvtO1CGvQUOdUUOZszjAm3zi8=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-1xTvW3Ra6erYpjxgfp2m8qVMz6u99WCDv2VE/Xh2mFc=";
  # reqwest's native-tls-vendored feature flag uses vendored openssl. this disables that
  env.OPENSSL_NO_VENDOR = true;
  # tests flaky on darwin on hydra
  doCheck = !stdenv.hostPlatform.isDarwin;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/rojo";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Project management tool for Roblox";

    longDescription = ''
      Tool designed to enable Roblox developers to use professional-grade software engineering tools.
    '';

    homepage = "https://rojo.space";
    changelog = "https://github.com/rojo-rbx/rojo/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ HeitorAugustoLN ];
    mainProgram = "rojo";
    downloadPage = "https://github.com/rojo-rbx/rojo/releases/tag/v${finalAttrs.version}";
  };
})
