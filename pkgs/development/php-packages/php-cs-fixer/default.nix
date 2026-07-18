{
  lib,
  fetchFromGitHub,
  php,
  versionCheckHook,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "php-cs-fixer";
  version = "3.95.1";

  src = fetchFromGitHub {
    owner = "PHP-CS-Fixer";
    repo = "PHP-CS-Fixer";
    tag = "v${finalAttrs.version}";
    hash = "sha256-nQSVAEb57kcboaqTa344eIsDC7qRiCAA6M9x77hsTio=";
  };

  vendorHash = "sha256-VIwZQutV2qlz0kZDQCncEM8Wa2zT9o+oM9O+FmhiTas=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  composerLock = ./composer.lock;
  passthru.updateScript = ./update.sh;

  meta = {
    description = "Tool to automatically fix PHP coding standards issues";
    homepage = "https://cs.symfony.com/";
    changelog = "https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.patka ];
    mainProgram = "php-cs-fixer";
  };
})
