{
  lib,
  fetchFromGitHub,
  # build-time
  autoPatchelfHook,
  buildGoModule,
  callPackage,
  copyDesktopItems,
  desktop-file-utils,
  # run-time
  gtk3,
  libayatana-appindicator,
  libx11,
  libxkbcommon,
  libxtst,
  makeDesktopItem,
  nodejs,
  pkg-config,
  replaceVars,
  xdg-utils,
}:
buildGoModule (finalAttrs: {
  pname = "wox";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "Wox-launcher";
    repo = "Wox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FbOnENSko/BYtTI7z2Ep+IIYufgZpNWcz6d0mqhTL5g=";
  };

  patches = [
    (replaceVars ./plugin-host-python.patch {
      plugin-host-python = "${finalAttrs.passthru.plugin-host-python}/bin/run";
    })
    (replaceVars ./plugin-host-nodejs.patch {
      nodejs-path = "${lib.getExe nodejs}";
      plugin-host-nodejs = "${finalAttrs.passthru.plugin-host-python}/node-host.js";
    })
  ];

  postPatch = ''
    substituteInPlace util/deeplink.go \
      --replace-fail "update-desktop-database" "${desktop-file-utils}/bin/update-desktop-database" \
      --replace-fail "xdg-mime" "${xdg-utils}/bin/xdg-mime"
  '';

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    pkg-config
  ];

  buildInputs = [
    gtk3
    libayatana-appindicator
    libx11
    libxkbcommon
    libxtst
  ];

  vendorHash = "sha256-IDcIEZVCJp1ls5c2fblgX+I+MhfRDXqFbf0GhgcFiTo=";
  env.CGO_ENABLED = 1;

  preBuild = ''
    mkdir -p resource/ui/flutter resource/hosts
    cp -r ${finalAttrs.passthru.ui-flutter}/app/${finalAttrs.passthru.ui-flutter.pname} resource/ui/flutter/wox
    cp ${finalAttrs.passthru.plugin-host-nodejs}/node-host.js resource/hosts/node-host.js
  '';

  # XOpenDisplay failure!
  # XkbGetKeyboard failed to locate a valid keyboard!
  doCheck = false;

  postInstall = ''
    install -Dm644 ../assets/app.png $out/share/icons/wox.png
  '';

  desktopItems = [
    (makeDesktopItem {
      desktopName = "Wox";
      exec = "wox %U";
      icon = "wox";
      name = "wox";
    })
  ];

  ldflags = [
    "-s"
    "-w"
    "-X 'wox/util.ProdEnv=true'"
  ];

  proxyVendor = true;
  sourceRoot = "${finalAttrs.src.name}/wox.core";

  passthru = {
    plugin-host-nodejs = callPackage ./plugin-host-nodejs.nix { };
    plugin-host-python = callPackage ./plugin-host-python.nix { };
    ui-flutter = callPackage ./ui-flutter.nix { };
  };

  meta = {
    description = "Cross-platform launcher that simply works";
    homepage = "https://github.com/Wox-launcher/Wox";
    changelog = "https://github.com/Wox-launcher/Wox/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ eljamm ];
    platforms = lib.platforms.linux;
    mainProgram = "wox";
  };
})
