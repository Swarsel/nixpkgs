{
  lib,
  fetchFromGitHub,
  php,
  versionCheckHook,
}:

(php.withExtensions ({ all, enabled }: enabled ++ [ all.pcov ])).buildComposerProject2
  (finalAttrs: {
    pname = "paratest";
    version = "7.23.0";

    src = fetchFromGitHub {
      owner = "paratestphp";
      repo = "paratest";
      tag = "v${finalAttrs.version}";
      hash = "sha256-Lqf+ZAI4JGFRT+n65403Wnz/OLvZuypJ49m/GZwgmmE=";
    };

    vendorHash = "sha256-oprzpm5EgTNi+FSU5CmgScEGq38L8o+GkjM8Fp/zKLk=";
    doInstallCheck = true;

    nativeInstallCheckInputs = [
      versionCheckHook
    ];

    composerLock = ./composer.lock;
    passthru.updateScript = ./update.sh;

    meta = {
      description = "Parallel testing for PHPUnit";
      homepage = "https://github.com/paratestphp/paratest";
      changelog = "https://github.com/paratestphp/paratest/releases/tag/v${finalAttrs.version}";
      license = lib.licenses.mit;

      maintainers = [
        lib.maintainers.patka
        lib.maintainers.piotrkwiecinski
      ];

      mainProgram = "paratest";
    };
  })
