{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_24,
  npm-lockfile-fix,
  snyk,
  testers,
}:

buildNpmPackage (finalAttrs: {
  pname = "snyk";
  version = "1.1306.0";

  src = fetchFromGitHub {
    owner = "snyk";
    repo = "cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SYF5o/yx8A3u81yCwIU3njVSLG2vZskhZhJSAXAEioA=";

    # TODO: Remove once https://github.com/snyk/cli/pull/6924 is released.
    postFetch = ''
      ${lib.getExe npm-lockfile-fix} $out/package-lock.json
    '';
  };

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail '"version": "1.0.0-monorepo"' '"version": "${finalAttrs.version}"'
  '';

  npmDepsHash = "sha256-6re7WgeeuiHSJJmr+3wWyHYEq+jcVy9FvkwwVwwdnBg=";

  postInstall = ''
    # Remove dangling symlinks created during installation (remove -delete to just see the files, or -print '%l\n' to see the target
    find -L $out -type l -print -delete
  '';

  nodejs = nodejs_24;
  npmBuildScript = "build:prod";
  npmDepsFetcherVersion = 3;

  passthru.tests.version = testers.testVersion {
    package = snyk;
  };

  meta = {
    description = "Scans and monitors projects for security vulnerabilities";
    homepage = "https://snyk.io";
    changelog = "https://github.com/snyk/cli/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ iamanaws ];
    mainProgram = "snyk";
  };
})
