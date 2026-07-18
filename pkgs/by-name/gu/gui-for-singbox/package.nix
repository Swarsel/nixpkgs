{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  buildGo126Module,
  copyDesktopItems,
  fetchPnpmDeps,
  glib-networking,
  makeDesktopItem,
  nix-update-script,
  nodejs,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  wails,
  webkitgtk_4_1,
  wrapGAppsHook3,
}:

let
  pname = "gui-for-singbox";
  version = "1.25.4";

  src = fetchFromGitHub {
    owner = "GUI-for-Cores";
    repo = "GUI.for.SingBox";
    tag = "v${version}";
    hash = "sha256-+2MdFF1iufbPJvf5XGrM9t9vaY7BNdIu/vSWgAKcbvQ=";
  };

  metaCommon = {
    homepage = "https://github.com/GUI-for-Cores/GUI.for.SingBox";
    hydraPlatforms = [ ]; # https://gui-for-cores.github.io/guide/#note
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = with lib.maintainers; [ vollate ];
  };

  frontend = stdenv.mkDerivation (finalAttrs: {
    inherit pname version src;
    patches = [ ./frontend-runtime-path.patch ];

    nativeBuildInputs = [
      nodejs
      pnpmConfigHook
      pnpm_10
    ];

    buildPhase = ''
      runHook preBuild

      pnpm run build-only

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist $out

      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        src
        sourceRoot
        ;

      fetcherVersion = 3;
      hash = "sha256-BrDO9xdMuMnhXPAd9QvtU4R1W1WacnsVcGde+WFjvGA=";
      pnpm = pnpm_10;
    };

    sourceRoot = "${finalAttrs.src.name}/frontend";

    meta = metaCommon // {
      description = "GUI program developed by vue3";
      platforms = lib.platforms.all;
    };
  });
in

buildGo126Module {
  inherit pname version src;
  patches = [ ./xdg-path-and-restart-patch.patch ];

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    pkg-config
    wails
    wrapGAppsHook3
  ];

  buildInputs = [
    glib-networking
    webkitgtk_4_1
  ];

  vendorHash = "sha256-Xi/EgMLex25p2tmRHEldCv6hgUKIpLJTmrMpHPGLY5M=";

  preBuild = ''
    cp -r ${frontend} frontend/dist
  '';

  buildPhase = ''
    runHook preBuild

    wails build -m -s -trimpath -skipbindings -devtools -tags webkit2_41 -o GUI.for.SingBox

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm 0755 build/bin/GUI.for.SingBox $out/bin/GUI.for.SingBox
    install -Dm 0644 build/appicon.png $out/share/icons/hicolor/256x256/apps/gui-for-singbox.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Network" ];
      desktopName = "GUI.for.SingBox";
      exec = "GUI.for.SingBox";
      genericName = "GUI.for.SingBox";
      icon = "gui-for-singbox";
      keywords = [ "Proxy" ];
      name = "gui-for-singbox";
    })
  ];

  passthru = {
    inherit frontend;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "^v([0-9.]+)$"
        "--subpackage"
        "frontend"
      ];
    };
  };

  meta = metaCommon // {
    description = "SingBox GUI program developed by vue3 + wails";
    platforms = lib.platforms.linux;
    mainProgram = "GUI.for.SingBox";
  };
}
