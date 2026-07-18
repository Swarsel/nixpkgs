{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  textlint,
  textlint-rule-preset-ja-spacing,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-preset-ja-spacing";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "textlint-ja";
    repo = "textlint-rule-preset-ja-spacing";
    tag = "v${finalAttrs.version}";
    hash = "sha256-M27qhjIHMcKbuPAh523Pi5IB5BD0VWawh84kUyLcKvg=";
  };

  nativeBuildInputs = [
    nodejs
    yarnBuildHook
    yarnConfigHook
  ];

  installPhase = ''
    runHook preInstall

    yarn install \
      --force \
      --frozen-lockfile \
      --ignore-engines \
      --ignore-platform \
      --ignore-scripts \
      --no-progress \
      --non-interactive \
      --offline \
      --production=true

    mkdir -p $out/lib
    cp -r . $out/lib

    runHook postInstall
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-AfbYACqYBvfsKzhryQabXQQmera19N/UH67sR5kbihM=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.tests = textlint.testPackages {
    rule = textlint-rule-preset-ja-spacing;
    testFile = ./test.md;
  };

  meta = {
    description = "スペース周りのスタイルを扱うtextlintルールプリセット";
    homepage = "https://github.com/textlint-ja/textlint-rule-preset-ja-spacing";
    changelog = "https://github.com/textlint-ja/textlint-rule-preset-ja-spacing/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = textlint.meta.platforms;
  };
})
