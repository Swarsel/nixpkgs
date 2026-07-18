{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "yo";
  version = "7.0.1";

  src = fetchFromGitHub {
    owner = "yeoman";
    repo = "yo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Xj8rz7YQMbCW2Dzyojiz0r6fgEkNG8D7xsf3KqE2tX4=";
  };

  npmDepsHash = "sha256-sBQLgiVEIrgKDgFdDfFqm8kRyiiPw2tOpHhA7ah5UVw=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  dontNpmBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "CLI tool for running Yeoman generators";
    homepage = "https://github.com/yeoman/yo";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ chillcicada ];
    mainProgram = "yo";
  };
})
