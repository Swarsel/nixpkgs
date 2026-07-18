{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  fixup-yarn-lock,
  nodejs,
  textlint,
  textlint-rule-en-max-word-count,
  yarn,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "textlint-rule-en-max-word-count";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "textlint-rule";
    repo = "textlint-rule-en-max-word-count";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZZWN0PVHQBHcvJ53jDtD/6wLxBYmSHO7OXb5UQQAmyc=";
  };

  nativeBuildInputs = [
    fixup-yarn-lock
    nodejs
    yarn
  ];

  buildPhase = ''
    runHook preBuild

    yarn --offline build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    yarn --offline --production install
    rm -r test
    mkdir -p $out/lib/node_modules/textlint-rule-en-max-word-count
    cp -r . $out/lib/node_modules/textlint-rule-en-max-word-count/

    runHook postInstall
  '';

  configurePhase = ''
    runHook preConfigure

    export HOME=$(mktemp -d)
    yarn config --offline set yarn-offline-mirror "$offlineCache"
    fixup-yarn-lock yarn.lock
    yarn --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive install
    patchShebangs node_modules

    runHook postConfigure
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-3sEbvIfSaMz9pJalEKs7y05OVh+cKDg9jfLYmVyS53M=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  passthru.tests = textlint.testPackages {
    rule = textlint-rule-en-max-word-count;
    testFile = ./test.md;
  };

  meta = {
    description = "Textlint rule that specify the maximum word count of a sentence";
    homepage = "https://github.com/textlint-rule/textlint-rule-en-max-word-count";
    changelog = "https://github.com/textlint-rule/textlint-rule-en-max-word-count/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = textlint.meta.platforms;
  };
})
