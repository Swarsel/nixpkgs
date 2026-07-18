{
  lib,
  fetchFromGitLab,
  buildGoModule,
  libkrb5,
  ruby,
}:

buildGoModule (finalAttrs: {
  pname = "gitlab-shell";
  version = "14.50.0";

  # nixpkgs-update: no auto update
  src = fetchFromGitLab {
    owner = "gitlab-org";
    repo = "gitlab-shell";
    rev = "v${finalAttrs.version}";
    hash = "sha256-a9s+TCm5yKPjNh+BD9fm6iVA4H9KJiMyWNulY+7BKZo=";
  };

  patches = [
    ./remove-hardcoded-locations.patch
  ];

  buildInputs = [
    ruby
    libkrb5
  ];

  vendorHash = "sha256-ceSnQQTtGdLb0QGR9fDbGC0NtRPGqkyXJ6b0TRXkjQM=";
  doCheck = false;

  postInstall = ''
    cp -r "$NIX_BUILD_TOP/source"/{support,VERSION} $out/
  '';

  subPackages = [
    "cmd/gitlab-shell"
    "cmd/gitlab-sshd"
    "cmd/gitlab-shell-check"
    "cmd/gitlab-shell-authorized-principals-check"
    "cmd/gitlab-shell-authorized-keys-check"
  ];

  meta = {
    description = "SSH access and repository management app for GitLab";
    homepage = "http://www.gitlab.com/";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.gitlab ];
  };
})
