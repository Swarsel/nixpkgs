{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  installShellFiles,
  libGL,
  libgbm,
  libglvnd,
  libinput,
  nix-update-script,
  pango,
  pkgconf,
  rustPlatform,
  sqlite,
  udev,
  vulkan-loader,
  xkeyboard_config,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jay";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "mahkoh";
    repo = "jay";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-bdvcGO1E9fkmKiXQxc3nvISwjIAegY8g37HmxXolsmU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    installShellFiles
    pkgconf
  ];

  buildInputs = [
    libGL
    libgbm
    libinput
    pango
    sqlite
    udev
    vulkan-loader
    xkeyboard_config
  ];

  cargoHash = "sha256-5yjMPDh7liaa9+KntfdCzUXz4vWzTcAhFmXrnVZ+pjM=";

  checkFlags = [
    # these 5 tests fail in the lix sandbox because they rely on io_uring
    "--skip=cpu_worker::tests::cancel"
    "--skip=cpu_worker::tests::complete"
    "--skip=eventfd_cache::tests::test"
    "--skip=io_uring::ops::read_write_no_cancel::tests::cancel_in_kernel"
    "--skip=io_uring::ops::read_write_no_cancel::tests::cancel_in_userspace"
  ];

  postInstall = ''
    install -D etc/jay.portal $out/share/xdg-desktop-portal/portals/jay.portal
    install -D etc/jay-portals.conf $out/share/xdg-desktop-portal/jay-portals.conf
    install -D etc/jay.desktop $out/share/wayland-sessions/jay.desktop
  ''
  + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd jay \
      --bash <("$out/bin/jay" generate-completion bash) \
      --zsh <("$out/bin/jay" generate-completion zsh) \
      --fish <("$out/bin/jay" generate-completion fish)
  '';

  runtimeDependencies = [
    libglvnd
  ];

  passthru = {
    providedSessions = [ "jay" ];
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Wayland compositor written in Rust";
    homepage = "https://github.com/mahkoh/jay";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ uku3lig ];
    platforms = lib.platforms.linux;
    mainProgram = "jay";
  };
})
