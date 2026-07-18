{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  buildPackages,
  installShellFiles,
  libisoburn,
  libvirt,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "podman-bootc";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "bootc-dev";
    repo = "podman-bootc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hxg2QSedPAWYZpuesUEFol9bpTppjB0/MpCcB+txMDc=";
  };

  patches = [ ./respect-home-env.patch ];

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [
    libvirt
    libisoburn
  ];

  vendorHash = "sha256-8QP4NziLwEo0M4NW5UgSEMAVgBDxmnE+PLbpyclK9RQ=";
  # All tests depend on booting virtual machines, which is infeasible here.
  doCheck = false;

  postInstall =
    let
      podman-bootc = "${stdenv.hostPlatform.emulator buildPackages} $out/bin/podman-bootc";
    in
    lib.optionalString (stdenv.hostPlatform.emulatorAvailable buildPackages) ''
      # podman-bootc always tries to touch cache and run dirs, no matter the command
      export HOME=$TMPDIR
      export XDG_RUNTIME_DIR=$TMPDIR

      installShellCompletion --cmd podman-bootc \
        --bash <(${podman-bootc} completion bash) \
        --fish <(${podman-bootc} completion fish) \
        --zsh <(${podman-bootc} completion zsh)
    '';

  tags = [
    "exclude_graphdriver_btrfs"
    "btrfs_noversion"
    "exclude_graphdriver_devicemapper"
    "containers_image_openpgp"
    "remote"
  ];

  meta = {
    description = "Streamlining podman+bootc interactions";
    homepage = "https://github.com/bootc-dev/podman-bootc";
    changelog = "https://github.com/bootc-dev/podman-bootc/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ evan-goode ];

    platforms = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-linux"
    ];

    mainProgram = "podman-bootc";
  };
})
