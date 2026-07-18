{
  lib,
  stdenv,
  fetchFromGitHub,
  darwin,
  electron,
  fetchPnpmDeps,
  makeDesktopItem,
  makeWrapper,
  nix-update-script,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  vikunja,
}:

let
  executableName = "vikunja-desktop";
  version = "2.3.0";
  src = fetchFromGitHub {
    owner = "go-vikunja";
    repo = "vikunja";
    rev = "v${version}";
    hash = "sha256-bdHiSFaN0vNQMhy6GPlpoFeYrk2CLvO7E30d8J/9GC0=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = finalAttrs.name;

  patches = [
    # pnpm 10.29.3 changed `pnpm ls --json`; older electron-builder omits runtime deps.
    # This patch was generated from the v2.3.0 lockfile with pnpm_10, using the
    # electron-builder 26.15.3 version already present in upstream main.
    ./electron-builder-26.15.3.patch
  ];

  nativeBuildInputs = [
    makeWrapper
    nodejs
    pnpm_10
    pnpmConfigHook
    vikunja.passthru.frontend
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    darwin.autoSignDarwinBinariesHook
  ];

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  buildPhase = ''
    runHook preBuild

    sed -i "s/\$${version}/${version}/g" package.json
    sed -i "s/\"version\": \".*\"/\"version\": \"${version}\"/" package.json
    ln -s '${vikunja.passthru.frontend}' frontend

    electronDist="${electron.dist}"
    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      electronDist="$(mktemp -d)"
      cp -R "${electron.dist}/." "$electronDist"
      chmod -R u+w "$electronDist"
      export CSC_IDENTITY_AUTO_DISCOVERY=false
    ''}
    pnpm run pack \
      -c.electronDist="$electronDist" \
      -c.electronVersion="${electron.version}" \
      ${lib.optionalString stdenv.hostPlatform.isDarwin "-c.mac.identity=null"}

    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall

    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      mkdir -p "$out/share/lib/vikunja-desktop"
      cp -r ./dist/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/vikunja-desktop"
      cp -r ./node_modules "$out/share/lib/vikunja-desktop/resources"

      install -Dm644 "build/icon.png" "$out/share/icons/hicolor/256x256/apps/vikunja-desktop.png"

      # use makeShellWrapper (instead of the makeBinaryWrapper provided by wrapGAppsHook3) for proper shell variable expansion
      # see https://github.com/NixOS/nixpkgs/issues/172583
      makeShellWrapper "${lib.getExe electron}" "$out/bin/vikunja-desktop" \
        --add-flags "$out/share/lib/vikunja-desktop/resources/app.asar" \
        "''${gappsWrapperArgs[@]}" \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=UseOzonePlatform,WaylandWindowDecorations,WebRTCPipeWireCapturer}}" \
        --set-default ELECTRON_IS_DEV 0 \
        --inherit-argv0
    ''}

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "$out/Applications" "$out/bin"
      mv ./dist/mac*/*.app "$out/Applications"
      makeWrapper \
        "$out/Applications/Vikunja Desktop.app/Contents/MacOS/Vikunja Desktop" \
        "$out/bin/vikunja-desktop"
    ''}

    runHook postInstall
  '';

  # The desktop item properties should be kept in sync with data from upstream:
  desktopItem = makeDesktopItem {
    categories = [
      "ProjectManagement"
      "Office"
    ];

    comment = finalAttrs.meta.description;
    desktopName = "Vikunja Desktop";
    exec = executableName;
    genericName = "To-Do list app";
    icon = "vikunja";
    name = "vikunja-desktop";
  };

  # Do not attempt generating a tarball for vikunja-frontend again.
  distPhase = ''
    true
  '';

  name = "vikunja-desktop-${version}";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      sourceRoot
      patches
      ;

    fetcherVersion = 4;
    hash = "sha256-2jyb5BYEkopZCbS19flUgCopiJWngyFxkXsyMuOpJEU=";
    pnpm = pnpm_10;
  };

  sourceRoot = "${finalAttrs.src.name}/desktop";
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (electron.meta) platforms;
    description = "Desktop App of the Vikunja to-do list app";
    homepage = "https://vikunja.io/";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ kolaente ];
    mainProgram = "vikunja-desktop";
  };
})
