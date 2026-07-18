{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  stdenvNoCC,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "ember-cli";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "ember-cli";
    repo = "ember-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xkMsPE+iweIV14m4kE4ytEp4uHMJW6gr+n9oJblr4VQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    yarnConfigHook
    yarnInstallHook
    nodejs
  ];

  offlineCache = fetchYarnDeps {
    hash = "sha256-QgT2JFvMupJo+pJc13n2lmHMZkROJRJWoozCho3E6+c=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  meta = {
    description = "Ember.js command line utility";
    homepage = "https://github.com/ember-cli/ember-cli";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jfvillablanca ];
    platforms = lib.platforms.all;
    mainProgram = "ember";
  };
})
