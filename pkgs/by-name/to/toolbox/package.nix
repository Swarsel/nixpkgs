{
  lib,
  fetchFromGitHub,
  buildGoModule,
  glibc,
  go-md2man,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "toolbox";
  version = "0.0.99.3";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "toolbox";
    rev = finalAttrs.version;
    hash = "sha256-9HiWgEtaMypLOwXJ6Xg3grLSZOQ4NInZtcvLPV51YO8=";
  };

  patches = [ ./glibc.patch ];

  postPatch = ''
    substituteInPlace src/cmd/create.go --subst-var-by glibc ${glibc}
  '';

  nativeBuildInputs = [
    go-md2man
    installShellFiles
  ];

  vendorHash = "sha256-k79TcC9voQROpJnyZ0RsqxJnBT83W5Z+D+D3HnuQGsI=";
  preCheck = "export PATH=$GOPATH/bin:$PATH";

  postInstall = ''
    cd ..
    for d in doc/*.md; do
      go-md2man -in $d -out ''${d%.md}
    done
    installManPage doc/*.[1-9]
    installShellCompletion --bash completion/bash/toolbox
    install profile.d/toolbox.sh -Dt $out/share/profile.d
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/containers/toolbox/pkg/version.currentVersion=${finalAttrs.version}"
  ];

  modRoot = "src";

  meta = {
    description = "Tool for containerized command line environments on Linux";
    homepage = "https://containertoolbx.org";
    changelog = "https://github.com/containers/toolbox/releases/tag/${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "toolbox";
  };
})
