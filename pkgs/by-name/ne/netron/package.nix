{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNpmPackage,
  electron_42,
  jq,
  makeDesktopItem,
}:

let
  electron = electron_42;
  description = "Visualizer for neural network, deep learning and machine learning models";
  icon = "netron";

in
buildNpmPackage (finalAttrs: {
  pname = "netron";
  version = "9.0.9";

  src = fetchFromGitHub {
    owner = "lutzroeder";
    repo = "netron";
    tag = "v${finalAttrs.version}";
    hash = "sha256-SNBNjMmOVkOpLGnzrXotUecQuEKii8bg22GPA1wiF3s=";
  };

  nativeBuildInputs = [ jq ];
  npmDepsHash = "sha256-KgMf4qWM8HeaZ6UQNVqLjbFZvlFZ/Y2YydI/dtGaeEw=";
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  preBuild = ''
    if [[ $(jq --raw-output '.devDependencies.electron' < package.json | grep -E --only-matching '^[0-9]+') != ${lib.escapeShellArg (lib.versions.major electron.version)} ]]; then
      echo 'ERROR: electron version mismatch'
      exit 1
    fi
  '';

  postBuild = ''
    npm exec electron-builder -- \
      --dir \
      --c.electronDist=${electron.dist} \
      --c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

    mkdir $out

    pushd dist/linux-${lib.optionalString stdenv.hostPlatform.isAarch64 "arm64-"}unpacked
    mkdir -p $out/opt/netron
    cp -r locales resources{,.pak} $out/opt/netron
    popd

    makeWrapper '${lib.getExe electron}' "$out/bin/netron" \
      --add-flags $out/opt/netron/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}" \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0

    pushd source
    for icon in icon.*; do
      dir=$out/share/icons/hicolor/"''${icon%.*}"/apps
      mkdir -p "$dir"
      cp "$icon" "$dir"/${icon}.png
    done
    popd

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      inherit icon;
      categories = [ "Development" ];
      comment = description;
      desktopName = "Netron";
      exec = "netron %U";
      name = "Netron";
    })
  ];

  # Do not run the default build script, it tries to do way too much that
  # wouldn't work on NixOS and require patching.
  dontNpmBuild = true;
  makeCacheWritable = true;

  meta = {
    inherit description;
    homepage = "https://netron.app";
    changelog = "https://github.com/lutzroeder/netron/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ flokli ];
    platforms = electron.meta.platforms;
    mainProgram = "netron";
  };
})
