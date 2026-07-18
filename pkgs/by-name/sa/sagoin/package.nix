{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sagoin";
  version = "0.2.4";

  src = fetchFromGitHub {
    owner = "figsoda";
    repo = "sagoin";
    rev = "v${finalAttrs.version}";
    hash = "sha256-zXYjR9ZFNX2guUSeMN/G77oBIlW3AowFWA4gwID2jQs=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-JM7m/VdaXpUlPOi+N7gue6mlQuxvRFU6++SaSq45Ntg=";
  env.GEN_ARTIFACTS = "artifacts";

  postInstall = ''
    installManPage artifacts/sagoin.1
    installShellCompletion artifacts/sagoin.{bash,fish} --zsh artifacts/_sagoin
  '';

  meta = {
    description = "Command-line submission tool for the UMD CS Submit Server";
    homepage = "https://github.com/figsoda/sagoin";
    changelog = "https://github.com/figsoda/sagoin/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ figsoda ];
    mainProgram = "sagoin";
  };
})
