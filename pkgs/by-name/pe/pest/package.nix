{
  lib,
  fetchFromGitHub,
  php,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "pest";
  version = "3.7.4";

  src = fetchFromGitHub {
    owner = "pestphp";
    repo = "pest";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ddsdVx/Vsg7GG11fGASouBU3HAJLSjs1AQGHx52TWzA=";
  };

  vendorHash = "sha256-Lv+wbOJVO7gGs4bOcECKyaw7+k3Z4f8gbNEv9uk4he8=";
  composerLock = ./composer.lock;

  meta = {
    description = "PHP testing framework";
    homepage = "https://pestphp.com";
    changelog = "https://github.com/pestphp/pest/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.patka ];
    mainProgram = "pest";
  };
})
