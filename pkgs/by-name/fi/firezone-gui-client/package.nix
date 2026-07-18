{
  lib,
  fetchFromGitHub,
  cargo-tauri,
  copyDesktopItems,
  dbus,
  fetchPnpmDeps,
  gdk-pixbuf,
  glib,
  gobject-introspection,
  gtk3,
  kdePackages,
  libayatana-appindicator,
  libsoup_3,
  makeDesktopItem,
  nix-update-script,
  nodejs,
  openssl,
  pkg-config,
  pnpmConfigHook,
  pnpm_10,
  rust,
  rustPlatform,
  stdenvNoCC,
  webkitgtk_4_1,
  wrapGAppsHook3,
  zenity,
}:
let
  version = "1.5.2";
  src = fetchFromGitHub {
    owner = "firezone";
    repo = "firezone";
    tag = "gui-client-${version}";
    hash = "sha256-Ew6oLVL7u9RtidHNsz29lzH9WPxKNneEoVACuLdP7yo=";
  };

  frontend = stdenvNoCC.mkDerivation rec {
    inherit version src;
    pname = "firezone-gui-client-frontend";

    nativeBuildInputs = [
      pnpmConfigHook
      pnpm_10
      nodejs
    ];

    env.GITHUB_SHA = version;

    buildPhase = ''
      runHook preBuild

      cd $pnpmRoot
      node ./node_modules/flowbite-react/dist/cli/bin.js patch
      node --max_old_space_size=1024000 ./node_modules/vite/bin/vite.js build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp -r dist $out

      runHook postInstall
    '';

    pnpmDeps = fetchPnpmDeps {
      inherit pname version;
      src = "${src}/rust/gui-client";
      fetcherVersion = 4;
      hash = "sha256-770+06rpf/P9hOFLgEWc0/BKjIxHyCWB2E3tqdEskAA=";
      pnpm = pnpm_10;
    };

    pnpmRoot = "rust/gui-client";
  };
in
rustPlatform.buildRustPackage rec {
  inherit version src;
  pname = "firezone-gui-client";

  # Required to remove profiling arguments which conflict with this builder
  postPatch = ''
    rm .cargo/config.toml
    ln -s ${frontend} gui-client/dist

    substituteInPlace gui-client/src-tauri/tauri.conf.json \
      --replace-fail '../../target' '../../target/${rust.envVars.rustHostPlatformSpec}'
  '';

  nativeBuildInputs = [
    cargo-tauri.hook
    pkg-config
    wrapGAppsHook3
    copyDesktopItems
  ];

  buildInputs = [
    openssl
    dbus
    gdk-pixbuf
    glib
    gobject-introspection
    gtk3
    libsoup_3

    libayatana-appindicator
    webkitgtk_4_1
  ];

  cargoHash = "sha256-LHHaklGIMuDuZwikXiQzLPbmkUbPyYR04UBQTBxq2ps=";
  env.RUSTFLAGS = "--cfg system_certs";
  # Tries to compile apple specific crates due to workspace dependencies,
  # not sure if this can be worked around
  doCheck = false;

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix PATH ":" ${
        lib.makeBinPath [
          zenity
          kdePackages.kdialog
        ]
      }
      --prefix LD_LIBRARY_PATH ":" ${
        lib.makeLibraryPath [
          libayatana-appindicator
        ]
      }
    )
  '';

  buildAndTestSubdir = "gui-client";

  desktopItems = [
    # Additional desktop item to associate deep-links
    (makeDesktopItem {
      categories = [ "Network" ];
      comment = meta.description;
      desktopName = "Firezone GUI Client";
      exec = "firezone-client-gui open-deep-link %U";
      icon = "firezone-client-gui";

      mimeTypes = [
        "x-scheme-handler/firezone-fd0020211111"
      ];

      name = "firezone-client-gui-deep-link";
      noDisplay = true;
    })
  ];

  sourceRoot = "${src.name}/rust";

  passthru = {
    inherit frontend;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "gui-client-(.*)"
      ];
    };
  };

  meta = {
    description = "GUI client for the Firezone zero-trust access platform";
    homepage = "https://github.com/firezone/firezone";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      oddlama
      patrickdag
    ];

    platforms = lib.platforms.linux;
    mainProgram = "firezone-gui-client";
  };
}
