{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nix-update-script,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "eask-cli";
  version = "0.12.9";

  src = fetchFromGitHub {
    owner = "emacs-eask";
    repo = "cli";
    tag = finalAttrs.version;
    hash = "sha256-jYdx+MYgUop01MzcKPxtm+ZW6lsy9eCqH00uQd8imRw=";
  };

  npmDepsHash = "sha256-Xj68un97I8xtAY3RXEq8PNC8ZOZ+NWg6SblnmKzHGMo=";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontBuild = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--use-github-releases" ];
  };

  meta = {
    description = "CLI for building, runing, testing, and managing your Emacs Lisp dependencies";
    homepage = "https://emacs-eask.github.io/";
    changelog = "https://github.com/emacs-eask/cli/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      jcs090218
      piotrkwiecinski
    ];

    mainProgram = "eask";
  };
})
