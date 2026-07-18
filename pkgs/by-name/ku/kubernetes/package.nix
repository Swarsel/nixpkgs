{
  lib,
  fetchFromGitHub,
  buildGoModule,
  installShellFiles,
  kubectl,
  makeWrapper,
  nix-update-script,
  nixosTests,
  rsync,
  runtimeShell,
  which,
  components ? [
    "cmd/kubeadm"
    "cmd/kubelet"
    "cmd/kube-apiserver"
    "cmd/kube-controller-manager"
    "cmd/kube-proxy"
    "cmd/kube-scheduler"
  ],
}:

buildGoModule (finalAttrs: {
  pname = "kubernetes";
  version = "1.36.2";

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "kubernetes";
    tag = "v${finalAttrs.version}";
    hash = "sha256-vE+2iBoJvkRhJDAHMCrJLIJKD53YWRBN6fBUP4589OU=";
  };

  outputs = [
    "out"
    "man"
    "pause"
  ];

  patches = [ ./fixup-addonmanager-lib-path.patch ];

  nativeBuildInputs = [
    makeWrapper
    which
    rsync
    installShellFiles
  ];

  vendorHash = null;
  env.WHAT = toString components;

  buildPhase = ''
    runHook preBuild
    substituteInPlace "hack/update-generated-docs.sh" --replace "make" "make SHELL=${runtimeShell}"
    patchShebangs ./hack ./cluster/addons/addon-manager
    make "SHELL=${runtimeShell}" "WHAT=$WHAT"
    ./hack/update-generated-docs.sh
    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    for p in $WHAT; do
      install -D _output/local/go/bin/''${p##*/} -t $out/bin
    done

    cc build/pause/linux/pause.c -o pause
    install -D pause -t $pause/bin

    rm docs/man/man1/kubectl*
    installManPage docs/man/man1/*.[1-9]

    ln -s ${kubectl}/bin/kubectl $out/bin/kubectl

    # Unfortunately, kube-addons-main.sh only looks for the lib file in either the
    # current working dir or in /opt. We have to patch this for now.
    substitute cluster/addons/addon-manager/kube-addons-main.sh $out/bin/kube-addons \
      --subst-var out

    chmod +x $out/bin/kube-addons
    wrapProgram $out/bin/kube-addons --set "KUBECTL_BIN" "$out/bin/kubectl"

    cp cluster/addons/addon-manager/kube-addons.sh $out/bin/kube-addons-lib.sh

    installShellCompletion --cmd kubeadm \
      --bash <($out/bin/kubeadm completion bash) \
      --zsh <($out/bin/kubeadm completion zsh)
    runHook postInstall
  '';

  passthru = {
    tests = nixosTests.kubernetes // {
      inherit kubectl;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Production-Grade Container Scheduling and Management";
    homepage = "https://kubernetes.io";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    teams = [ lib.teams.kubernetes ];
  };
})
