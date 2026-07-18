{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "github-release";
  version = "0.11.0";

  src = fetchFromGitHub {
    owner = "github-release";
    repo = "github-release";
    tag = "v${finalAttrs.version}";
    hash = "sha256-foQZsYfYM/Cqtck+xfdup6WUeoBiqBTP7USCyPMv5q0=";
  };

  vendorHash = null;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  ldflags = [ "-s" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Commandline app to create and edit releases on Github (and upload artifacts)";

    longDescription = ''
      A small commandline app written in Go that allows you to easily create and
      delete releases of your projects on Github.
      In addition it allows you to attach files to those releases.
    '';

    homepage = "https://github.com/github-release/github-release";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      ardumont
    ];

    mainProgram = "github-release";
  };
})
