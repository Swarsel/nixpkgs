{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "git-pr";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "picosh";
    repo = "git-pr";
    tag = "v${finalAttrs.version}";
    hash = "sha256-2A2rP7yr8faVoIYAWprr+t7MwDPerhsuOjWWEl1mhXw=";
  };

  vendorHash = "sha256-7aHr5CWZVmhBiuCXaK49zYJXMufCxZBnS917mF0QJlg=";
  env.CGO_ENABLED = 0;

  postInstall = ''
    mv $out/bin/ssh $out/bin/git-ssh
    mv $out/bin/web $out/bin/git-web
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [
    "cmd/ssh"
    "cmd/web"
  ];

  meta = {
    description = "Simple git collaboration tool";
    homepage = "https://pr.pico.sh";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sigmanificient
      jolheiser
    ];

    mainProgram = "git-ssh";
  };
})
