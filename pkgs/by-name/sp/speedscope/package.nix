{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  versionCheckHook,
}:

buildNpmPackage (finalAttrs: {
  pname = "speedscope";
  version = "1.25.0";

  src = fetchFromGitHub {
    owner = "jlfwong";
    repo = "speedscope";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2kBgOMWSr3XEkcfzetA4njIE2co+mHoPPUFmKn0tMVk=";
    # scripts/prepack.sh wants to extract the git commit from .git
    # We don't want to keep .git for reproducibility reasons, so save the commit
    # to a file and patch the script.
    leaveDotGit = true;

    postFetch = ''
      ( cd $out; git rev-parse HEAD > COMMIT )
      rm -rf $out/.git
    '';
  };

  patches = [
    ./fix-shebang.patch
  ];

  npmDepsHash = "sha256-hgvO5iU9lerTa9FJRHq9lm67lgrFSM5AR02GShsM3P8=";

  postConfigure = ''
    patchShebangs scripts
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  dontNpmBuild = true;

  meta = {
    description = "Fast and interactive web-based viewer for performance profiles";
    homepage = "https://github.com/jlfwong/speedscope";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thomasjm ];
    platforms = lib.platforms.linux;
    mainProgram = "speedscope";
  };
})
