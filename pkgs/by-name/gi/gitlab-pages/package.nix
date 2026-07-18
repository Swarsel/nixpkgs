{
  lib,
  fetchFromGitLab,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gitlab-pages";
  version = "18.11.6";

  # nixpkgs-update: no auto update
  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "gitlab-pages";
    rev = "v${finalAttrs.version}";
    hash = "sha256-D/AlIXbcgvPyP2TX/lXVYlnG2HXKZlxOhqRTfTXsaew=";
  };

  vendorHash = "sha256-PUW4cgAiM1GTtvja894OZ4pe0SWChf5JsL4/fkns2kI=";

  ldflags = [
    "-X"
    "main.VERSION=${finalAttrs.version}"
  ];

  subPackages = [ "." ];

  meta = {
    description = "Daemon used to serve static websites for GitLab users";
    homepage = "https://gitlab.com/gitlab-org/gitlab-pages";
    changelog = "https://gitlab.com/gitlab-org/gitlab-pages/-/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "gitlab-pages";
    teams = [ lib.teams.gitlab ];
  };
})
