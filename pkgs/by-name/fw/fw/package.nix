{
  lib,
  fetchFromGitHub,
  libgit2,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
  zlib,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fw";
  version = "2.21.0";

  src = fetchFromGitHub {
    owner = "brocode";
    repo = "fw";
    tag = "v${finalAttrs.version}";
    hash = "sha256-tqtiAw4+bnCJMF37SluAE9NM55MAjBGkJTvGLcmYFnA=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
    zlib
  ];

  cargoHash = "sha256-B32GegI3rvame0Ds+8+oBVUbcNhr2kwm3oVVxng8BZY=";

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Workspace productivity booster";
    homepage = "https://github.com/brocode/fw";
    license = lib.licenses.wtfpl;
    maintainers = [ lib.maintainers.progrm_jarvis ];
    mainProgram = "fw";
  };
})
