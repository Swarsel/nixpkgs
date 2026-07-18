{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "aasvg";
  version = "0.5.3";

  src = fetchFromGitHub {
    owner = "martinthomson";
    repo = "aasvg";
    tag = "v${finalAttrs.version}";
    hash = "sha256-D3ompmRt9Mxmzr0TxFLBrSl/dNE986TZbOvfuyk9rJo=";
  };

  npmDepsHash = "sha256-FdVXR2Myit3GiA1/VXzHBRSihKAQlh+Zd1gzSMuYi6c=";
  # the project has no dependencies
  preInstall = "mkdir node_modules/";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontNpmBuild = true;
  forceEmptyCache = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Convert ASCII art diagrams into SVG";
    homepage = "https://github.com/martinthomson/aasvg";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ chillcicada ];
    platforms = lib.platforms.all;
    mainProgram = "aasvg";
  };
})
