{
  lib,
  stdenv,
  fetchFromGitHub,
  OVMF,
  buildGoModule,
  installShellFiles,
  libvirt,
  makeWrapper,
  pkg-config,
  qemu,
  versionCheckHook,
  which,
  writableTmpDirAsHomeHook,
  withQemu ? false,
}:

buildGoModule (finalAttrs: {
  pname = "minikube";
  version = "1.38.1";

  src = fetchFromGitHub {
    owner = "kubernetes";
    repo = "minikube";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1unwbu2pJviHXukQKalJLgrkHpjf0sRR2nCm2gKv2VU=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail "export GOTOOLCHAIN := go\$(GO_VERSION)" "export GOTOOLCHAIN := local"
  ''
  + (lib.optionalString (withQemu && stdenv.hostPlatform.isDarwin) ''
    substituteInPlace \
      pkg/minikube/registry/drvs/qemu2/qemu2.go \
      --replace "/usr/local/opt/qemu/share/qemu" "${qemu}/share/qemu" \
      --replace "/opt/homebrew/opt/qemu/share/qemu" "${qemu}/share/qemu"
  '')
  + (lib.optionalString (withQemu && stdenv.hostPlatform.isLinux) ''
    substituteInPlace \
      pkg/minikube/registry/drvs/qemu2/qemu2.go \
      --replace "/usr/share/OVMF/OVMF_CODE.fd" "${OVMF.firmware}" \
      --replace "/usr/share/AAVMF/AAVMF_CODE.fd" "${OVMF.firmware}"
  '');

  nativeBuildInputs = [
    installShellFiles
    pkg-config
    which
    makeWrapper
    writableTmpDirAsHomeHook
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ libvirt ];
  vendorHash = "sha256-Oy8cM/foZKC83PxqkJW+o8vVYJhszKxXs9l2eks7FN4=";

  buildPhase = ''
    runHook preBuild

    make COMMIT=${finalAttrs.src.rev}

    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    installBin out/minikube

    wrapProgram $out/bin/minikube --set MINIKUBE_WANTUPDATENOTIFICATION false
    ln -sv $out/bin/minikube $out/bin/kubectl

    for shell in bash zsh fish; do
      $out/bin/minikube completion $shell > minikube.$shell
      installShellCompletion minikube.$shell
    done

    runHook postInstall
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
    writableTmpDirAsHomeHook
  ];

  __structuredAttrs = true;
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "version";

  meta = {
    description = "Tool that makes it easy to run Kubernetes locally";
    homepage = "https://minikube.sigs.k8s.io";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      vdemeester
      atkinschang
      Chili-Man
    ];

    mainProgram = "minikube";
  };
})
