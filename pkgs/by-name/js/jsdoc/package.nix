{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
}:

buildNpmPackage (finalAttrs: {
  pname = "jsdoc";
  version = "5.0.0-dev.19";

  src = fetchFromGitHub {
    owner = "jsdoc";
    repo = "jsdoc";
    tag = "jsdoc@${finalAttrs.version}";
    hash = "sha256-dd68veLr78YRw06o/KzlhHtmSznnu7XHK6gTu6V4sJU=";
  };

  npmDepsHash = "sha256-29xgiKNGwVNv+l3ou3RNamBNp0ykbDlUCsnlo0CEcSI=";

  postBuild = ''
    npm run test
  '';

  postInstall = ''
    mkdir -p $out/lib/node_modules/jsdoc/packages
    mv packages/* $out/lib/node_modules/jsdoc/packages
  '';

  dontNpmBuild = true;
  npmWorkspace = "packages/jsdoc";

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--use-github-releases"
      "--version=unstable"
      "--version-regex"
      "jsdoc@(.*)"
    ];
  };

  meta = {
    description = "API documentation generator for JavaScript";
    homepage = "https://jsdoc.app";
    changelog = "https://github.com/jsdoc/jsdoc/releases/jsdoc@${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
})
