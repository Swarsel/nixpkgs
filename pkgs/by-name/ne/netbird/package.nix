{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  gtk3,
  installShellFiles,
  libayatana-appindicator,
  libx11,
  libxcursor,
  libxxf86vm,
  netbird-management,
  netbird-proxy,
  netbird-relay,
  netbird-signal,
  netbird-ui,
  netbird-upload,
  nix-update-script,
  nixosTests,
  pkg-config,
  versionCheckHook,
  componentName ? "client",
}:
let
  /*
    License tagging is based off:
    - https://github.com/netbirdio/netbird/blob/9e95841252c62b50ae93805c8dfd2b749ac95ea7/LICENSES/REUSE.toml
    - https://github.com/netbirdio/netbird/blob/9e95841252c62b50ae93805c8dfd2b749ac95ea7/LICENSE#L1-L2
  */
  availableComponents = {
    client = {
      binaryName = "netbird";
      hasCompletion = true;
      license = lib.licenses.bsd3;
      module = "client";
      versionCheckProgramArg = "version";
    };

    management = {
      binaryName = "netbird-mgmt";
      hasCompletion = true;
      license = lib.licenses.agpl3Only;
      module = "management";
      versionCheckProgramArg = "--version";
    };

    proxy = {
      binaryName = "netbird-proxy";
      license = lib.licenses.agpl3Only;
      module = "proxy/cmd/proxy";
    };

    relay = {
      binaryName = "netbird-relay";
      license = lib.licenses.agpl3Only;
      module = "relay";
    };

    signal = {
      binaryName = "netbird-signal";
      hasCompletion = true;
      license = lib.licenses.agpl3Only;
      module = "signal";
    };

    ui = {
      binaryName = "netbird-ui";
      license = lib.licenses.bsd3;
      module = "client/ui";
    };

    upload = {
      binaryName = "netbird-upload";
      license = lib.licenses.bsd3;
      module = "upload-server";
    };
  };
  component = availableComponents.${componentName};
in
buildGoModule (finalAttrs: {
  pname = "netbird-${componentName}";
  version = "0.74.2";

  src = fetchFromGitHub {
    owner = "netbirdio";
    repo = "netbird";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+BGWZzw6a8Fp8NlhtbX81OA3hCTcQ9r6nLuXTsbXCZ8=";
  };

  postPatch = ''
    # make it compatible with systemd's RuntimeDirectory
    substituteInPlace client/cmd/root.go \
      --replace-fail 'unix:///var/run/netbird.sock' 'unix:///var/run/netbird/sock'
    substituteInPlace client/ui/client_ui.go \
      --replace-fail 'unix:///var/run/netbird.sock' 'unix:///var/run/netbird/sock'
  '';

  nativeBuildInputs = [ installShellFiles ] ++ lib.optional (componentName == "ui") pkg-config;

  buildInputs = lib.optionals (stdenv.hostPlatform.isLinux && componentName == "ui") [
    gtk3
    libayatana-appindicator
    libx11
    libxcursor
    libxxf86vm
  ];

  vendorHash = "sha256-5dZu6lmfwaUHusAlFS1qqorFbpa4anCUQDtg4Tv5mxw=";
  # needs network access
  doCheck = false;

  postInstall =
    let
      builtBinaryName = lib.last (lib.splitString "/" component.module);
    in
    ''
      mv $out/bin/${builtBinaryName} $out/bin/${component.binaryName}
    ''
    +
      lib.optionalString
        (stdenv.buildPlatform.canExecute stdenv.hostPlatform && (component.hasCompletion or false))
        ''
          installShellCompletion --cmd ${component.binaryName} \
            --bash <($out/bin/${component.binaryName} completion bash) \
            --fish <($out/bin/${component.binaryName} completion fish) \
            --zsh <($out/bin/${component.binaryName} completion zsh)
        ''
    # assemble & adjust netbird.desktop files for the GUI
    + lib.optionalString (stdenv.hostPlatform.isLinux && componentName == "ui") ''
      install -Dm644 "$src/client/ui/assets/netbird-systemtray-connected.png" "$out/share/icons/hicolor/256x256/apps/netbird.png"
      install -Dm644 "$src/client/ui/build/netbird.desktop" "$out/share/applications/netbird.desktop"

      substituteInPlace $out/share/applications/netbird.desktop \
        --replace-fail "Exec=/usr/bin/netbird-ui" "Exec=${component.binaryName}"
    '';

  nativeInstallCheckInputs = lib.lists.optionals (component ? versionCheckProgramArg) [
    versionCheckHook
  ];

  ldflags = [
    "-s"
    "-w"
    "-X github.com/netbirdio/netbird/version.version=v${finalAttrs.version}"
    "-X main.builtBy=nix"
  ];

  overrideModAttrs = final: prev: {
    # override output name so that we don't download the same modules every time
    # for every component of the monorepo
    name = "netbird-${finalAttrs.version}-go-modules";
  };

  subPackages = [ component.module ];
  versionCheckProgram = "${placeholder "out"}/bin/${component.binaryName}";
  versionCheckProgramArg = component.versionCheckProgramArg or "version";

  passthru = {
    tests = lib.attrsets.optionalAttrs (componentName == "client") {
      inherit
        # make sure child packages are built by `ofborg`
        netbird-management
        netbird-relay
        netbird-signal
        netbird-ui
        netbird-upload
        netbird-proxy
        ;

      nixos = nixosTests.netbird;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Connect your devices into a single secure private WireGuard®-based mesh network with SSO/MFA and simple access controls";
    homepage = "https://netbird.io";
    changelog = "https://github.com/netbirdio/netbird/releases/tag/v${finalAttrs.version}";
    license = component.license;

    maintainers = with lib.maintainers; [
      nazarewk
      saturn745
      loc
    ];

    mainProgram = component.binaryName;
  };
})
