{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
  yarnInstallHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "postlight-parser";
  version = "2.2.3";

  src = fetchFromGitHub {
    owner = "postlight";
    repo = "parser";
    rev = "v${finalAttrs.version}";
    hash = "sha256-k6m95FHeJ+iiWSeY++1zds/bo1RtNXbnv2spaY/M+L0=";
  };

  nativeBuildInputs = [
    yarnConfigHook
    yarnBuildHook
    yarnInstallHook
    nodejs
  ];

  postBuild = ''
    yarn --offline run rollup -c
  '';

  offlineCache = fetchYarnDeps {
    hash = "sha256-Vs8bfkhEbPv33ew//HBeDnpQcyWveByHi1gUsdl2CNI=";
    yarnLock = "${finalAttrs.src}/yarn.lock";
  };

  # Upstream doesn't include a script in package.json that only builds without
  # testing, and tests fail because they need to access online websites. Hence
  # we use the builtin interface of yarnBuildHook to lint, and in `postBuild`
  # we run the rest of commands needed to create the js files eventually
  # distributed and wrapped by npmHooks.npmInstallHook
  yarnBuildScript = "lint";

  meta = {
    description = "Extracts the bits that humans care about from any URL you give it";
    homepage = "https://reader.postlight.com";
    changelog = "https://github.com/postlight/parser/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ viraptor ];
    mainProgram = "postlight-parser";
  };
})
