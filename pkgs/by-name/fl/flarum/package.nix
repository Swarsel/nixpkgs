{
  lib,
  fetchFromGitHub,
  nixosTests,
  php,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "flarum";
  version = "1.8.1";

  src = fetchFromGitHub {
    owner = "flarum";
    repo = "flarum";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kigUZpiHTM24XSz33VQYdeulG1YI5s/M02V7xue72VM=";
  };

  vendorHash = "sha256-EHl+Mr6y5A51EpLPAWUGtiPkLOky6KvsSY4JWHeyO28=";
  composerLock = ./composer.lock;
  composerStrictValidation = false;
  passthru.tests.module = nixosTests.flarum;

  meta = {
    description = "Delightfully simple discussion platform for your website";
    homepage = "https://github.com/flarum/flarum";
    changelog = "https://github.com/flarum/framework/blob/main/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      fsagbuya
      jasonodoom
    ];
  };
})
