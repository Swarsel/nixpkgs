{
  lib,
  fetchFromGitHub,
  autoPatchelfHook,
  buildGoModule,
  copyDesktopItems,
  fetchNpmDeps,
  imagemagick,
  makeDesktopItem,
  nodejs,
  npmHooks,
  pkg-config,
  wails,
  webkitgtk_4_1,
  writeScript,
}:

buildGoModule (finalAttrs: {
  pname = "tiny-rdm";
  version = "1.2.7";

  src = fetchFromGitHub {
    owner = "tiny-craft";
    repo = "tiny-rdm";
    tag = "v${finalAttrs.version}";
    hash = "sha256-MyIMGgKzP6SnRzlOd4OQvMNiih7lsjfVFFckkPS2J+w=";
  };

  postPatch = ''
    substituteInPlace frontend/src/App.vue \
      --replace-fail "prefStore.autoCheckUpdate" "false"
  '';

  nativeBuildInputs = [
    wails
    pkg-config
    autoPatchelfHook
    nodejs
    npmHooks.npmConfigHook
    copyDesktopItems
    imagemagick
  ];

  buildInputs = [ webkitgtk_4_1 ];
  vendorHash = "sha256-DaD/NM1ZNVt0X/CJuaGfHqeS9ySTWFd0y5bzog6Yn+E=";

  env = {
    CGO_ENABLED = 1;

    npmDeps = fetchNpmDeps {
      src = "${finalAttrs.src}/frontend";
      hash = "sha256-DUYUk4OK5UWDanSR5hSVDYloYX4fYD41omYThzi/700=";
    };

    npmRoot = "frontend";
  };

  buildPhase = ''
    runHook preBuild

    wails build -m -trimpath -devtools -tags webkit2_41 -o tiny-rdm

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm 0755 build/bin/tiny-rdm $out/bin/tiny-rdm
    mkdir -p $out/share/icons/hicolor/96x96/apps
    magick frontend/src/assets/images/icon.png -resize 96x96 $out/share/icons/hicolor/96x96/apps/tiny-rdm.png

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [ "Office" ];
      comment = "Tiny Redis Desktop Manager";
      desktopName = "Tiny RDM";
      exec = "tiny-rdm %U";
      icon = "tiny-rdm";
      mimeTypes = [ "x-scheme-handler/tinyrdm" ];
      name = "tiny-rdm";
      startupWMClass = "tinyrdm";
      terminal = false;
      type = "Application";
    })
  ];

  passthru = {
    inherit (finalAttrs.env) npmDeps;

    updateScript = writeScript "update-tiny-rdm" ''
      #!/usr/bin/env nix-shell
      #!nix-shell -i bash -p bash nix nix-update common-updater-scripts
      set -eou pipefail
      version=$(nix eval --log-format raw --raw --file default.nix tiny-rdm.version)
      nix-update tiny-rdm || true
      latestVersion=$(nix eval --log-format raw --raw --file default.nix tiny-rdm.version)
      if [[ "$latestVersion" == "$version" ]]; then
        exit 0
      fi
      update-source-version tiny-rdm "$latestVersion" --source-key=npmDeps --ignore-same-version
      nix-update tiny-rdm --version skip
    '';
  };

  meta = {
    description = "Modern, colorful, super lightweight Redis GUI client";
    homepage = "https://github.com/tiny-craft/tiny-rdm";
    license = with lib.licenses; [ gpl3Plus ];
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "tiny-rdm";
  };
})
