{
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  meta,
  nodejs,
  yarnBuildHook,
  yarnConfigHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "strichliste-frontend";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "strichliste";
    repo = "strichliste-web-frontend";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LzTdFYuIIFmAVuHtGjljqSBZGEPibwXcK5WuYB6ELNg=";
  };

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
    yarnBuildHook
  ];

  env.NODE_OPTIONS = "--openssl-legacy-provider";

  installPhase = ''
    mkdir $out
    cp -R build/* $out/
  '';

  __structuredAttrs = true;

  yarnOfflineCache = fetchYarnDeps {
    hash = "sha256-leMwcsyhbxPoHJdA3kZDz97Ti77d1TCe8SrzTQMGrWo=";
    yarnLock = finalAttrs.src + "/yarn.lock";
  };

  meta = meta // {
    changelog = "https://github.com/strichliste/strichliste-web-frontend/releases/tag/${finalAttrs.src.tag}";
  };
})
