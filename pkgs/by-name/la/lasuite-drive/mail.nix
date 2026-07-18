{
  stdenv,
  fetchYarnDeps,
  meta,
  nodejs,
  src,
  version,
  yarnBuildHook,
  yarnConfigHook,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit src version;
  pname = "lasuite-drive-mail";

  postPatch = ''
    substituteInPlace bin/html-to-plain-text bin/mjml-to-html \
      --replace-fail \
        '../backend/core/templates/mail' \
        '${placeholder "out"}'
  '';

  nativeBuildInputs = [
    nodejs
    yarnConfigHook
    yarnBuildHook
  ];

  __structuredAttrs = true;
  dontInstall = true;

  offlineCache = fetchYarnDeps {
    hash = "sha256-UPIb9QJk+zC8wYeBeDnmlGLhHDhsEOoT+qquFM1XyqU=";
    yarnLock = "${finalAttrs.src}/src/mail/yarn.lock";
  };

  sourceRoot = "${finalAttrs.src.name}/src/mail";

  meta = meta // {
    description = "HTML mail templates for LaSuite Drive";
  };
})
