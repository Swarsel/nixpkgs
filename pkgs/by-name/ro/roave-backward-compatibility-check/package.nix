{
  lib,
  fetchFromGitHub,
  php,
  versionCheckHook,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "roave-backward-compatibility-check";
  version = "8.21.0";

  src = fetchFromGitHub {
    owner = "Roave";
    repo = "BackwardCompatibilityCheck";
    tag = finalAttrs.version;
    hash = "sha256-kCs9lDvbhUacOH4bEAZjm2LzHSvJnVMR9lzmt00GgTw=";
  };

  vendorHash = "sha256-68KE/ieWYST/jQMaaK5lLqBLEmI4YhYPOE4XuXNMfqM=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  meta = {
    description = "Tool that can be used to verify BC breaks between two versions of a PHP library";
    homepage = "https://github.com/Roave/BackwardCompatibilityCheck";
    changelog = "https://github.com/Roave/BackwardCompatibilityCheck/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "roave-backward-compatibility-check";
    teams = [ lib.teams.php ];
  };
})
