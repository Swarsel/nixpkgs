{
  lib,
  fetchFromGitHub,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fishy";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "p2panda";
    repo = "fishy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nRkP53v9+VzqHKTsHs+cBeLjh3yASFE18sSEY02NR1s=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-F4zbalop1PEb381DctUIzdm3v71b6M/hnuw9BuIEkBU=";
  env.OPENSSL_NO_VENDOR = 1;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Create, manage and deploy p2panda schemas";
    homepage = "https://github.com/p2panda/fishy";
    changelog = "https://github.com/p2panda/fishy/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ confusedalex ];
    mainProgram = "fishy";
  };
})
