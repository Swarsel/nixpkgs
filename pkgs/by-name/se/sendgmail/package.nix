{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:
buildGoModule (finalAttrs: {
  pname = "sendgmail";
  version = "0-unstable-2025-03-06";

  src = fetchFromGitHub {
    owner = "google";
    repo = "gmail-oauth2-tools";
    rev = "85c6b4f07e637683cc5e0ec6a66ce8e4397a4b18";
    hash = "sha256-bzbTU9SA4dJKtQVkqESvV5o3l3MY4Uy7HDqo7jI3dhM=";
  };

  vendorHash = "sha256-0pjcO2Ati+mUSw614uEL3CatHSgbgDUfOBE8bWpjmcw=";
  sourceRoot = "${finalAttrs.src.name}/go/sendgmail";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Mimic sendmail with Gmail for git send-email";
    homepage = "https://github.com/google/gmail-oauth2-tools/tree/master/go/sendgmail";
    license = lib.licenses.asl20;
    maintainers = [ lib.maintainers.samw ];
    platforms = lib.platforms.unix;
    mainProgram = "sendgmail";
  };
})
