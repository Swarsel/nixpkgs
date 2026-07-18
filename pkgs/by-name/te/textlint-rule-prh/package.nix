{
  lib,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  npmHooks,
  runCommand,
  stdenvNoCC,
  textlint,
  textlint-rule-prh,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "textlint-rule-prh";
  version = "6.0.0";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-prh";
    tag = "v${finalAttrs.version}";
    hash = "sha256-K2WkHh7sLnhObM2ThvdXVbZymLInjSB6XTshxALotKU=";
  };

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "git config --local core.hooksPath .githooks" ""
  '';

  nativeBuildInputs = [
    nodejs
    npmHooks.npmInstallHook
    yarnBuildHook
    yarnConfigHook
  ];

  offlineCache = fetchYarnDeps {
    hash = "sha256-tZMMadWue85L+5c7swKgFqUsLSARjS4EK0Cwi1FjX88=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.tests = {
    "textlint-rule-prh-test" =
      runCommand "textlint-rule-prh-test"
        { nativeBuildInputs = [ (textlint.withPackages [ textlint-rule-prh ]) ]; }
        ''
          substitute ${./textlintrc} .textlintrc \
            --subst-var-by textlint_rule_prh "${textlint-rule-prh}"

          grep prh <(textlint ${./test.md}) > $out
        '';
  };

  meta = {
    description = "Textlint rule for prh";
    homepage = "https://github.com/textlint-rule/textlint-rule-prh";
    changelog = "https://github.com/textlint-rule/textlint-rule-prh/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = textlint.meta.platforms;
  };
})
