{
  lib,
  fetchFromGitHub,
  installShellFiles,
  libxcb,
  libxcb-cursor,
  makeBinaryWrapper,
  nix-update-script,
  pkg-config,
  rustPlatform,
  xwayland,
  withSystemd ? true,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "xwayland-satellite";
  version = "0.8.1";

  src = fetchFromGitHub {
    owner = "Supreeeme";
    repo = "xwayland-satellite";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BUE41HjLIGPjq3U8VXPjf8asH8GaMI7FYdgrIHKFMXA=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace resources/xwayland-satellite.service \
      --replace-fail '/usr/local/bin' "$out/bin"
  '';

  nativeBuildInputs = [
    installShellFiles
    makeBinaryWrapper
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    libxcb
    libxcb-cursor
  ];

  cargoHash = "sha256-16L6gsvze+m7XCJlOA1lsPNELE3D364ef2FTdkh0rVY=";
  # All integration tests require a running display server
  doCheck = false;

  postInstall = ''
    installManPage --name xwayland-satellite.1 xwayland-satellite.man
  ''
  + lib.optionalString withSystemd ''
    install -Dm0644 resources/xwayland-satellite.service -t $out/lib/systemd/user
  '';

  postFixup = ''
    wrapProgram $out/bin/xwayland-satellite \
      --prefix PATH : "${lib.makeBinPath [ xwayland ]}"
  '';

  buildFeatures = lib.optional withSystemd "systemd";
  buildNoDefaultFeatures = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Xwayland outside your Wayland compositor";

    longDescription = ''
      Grants rootless Xwayland integration to any Wayland compositor implementing xdg_wm_base.
    '';

    homepage = "https://github.com/Supreeeme/xwayland-satellite";
    changelog = "https://github.com/Supreeeme/xwayland-satellite/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;

    maintainers = with lib.maintainers; [
      if-loop69420
      sodiboo
      getchoo
    ];

    platforms = lib.platforms.linux;
    mainProgram = "xwayland-satellite";
  };
})
