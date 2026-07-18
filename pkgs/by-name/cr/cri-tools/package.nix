{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
}:

buildGoModule (finalAttrs: {
  pname = "cri-tools";
  version = "1.36.0";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "cri-tools";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Ae0CL/BZdIBzZr+Tttg6sNhn1eS2E1odR6fGpbFRVjI=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = null;

  buildPhase = ''
    runHook preBuild
    make binaries VERSION=${finalAttrs.version}
    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    make install BINDIR=$out/bin
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    for shell in bash fish zsh; do
      installShellCompletion --cmd crictl \
        --$shell <($out/bin/crictl completion $shell)
    done
  ''
  + ''
    runHook postInstall
  '';

  meta = {
    description = "CLI and validation tools for Kubelet Container Runtime Interface (CRI)";
    homepage = "https://github.com/kubernetes-sigs/cri-tools";
    license = lib.licenses.asl20;
    teams = [ lib.teams.podman ];
  };
})
