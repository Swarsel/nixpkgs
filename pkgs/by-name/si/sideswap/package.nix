{
  lib,
  fetchFromGitHub,
  # Needed for update script.
  _experimental-update-script-combinators,
  callPackage,
  copyDesktopItems,
  dart,
  flutter341,
  gitUpdater,
  makeDesktopItem,
  runCommand,
  sideswap,
  yq-go,
}:

let
  # The Rust library is used by the main application.
  libsideswap-client = callPackage ./libsideswap-client.nix { };
in

flutter341.buildFlutterApplication (finalAttrs: {
  pname = "sideswap";
  version = "1.9.0";

  src = fetchFromGitHub {
    owner = "sideswap-io";
    repo = "sideswapclient";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E+njx//oCr85nwF8rvuOjDTNvs5177+lh9uy5LEvTVE=";
  };

  nativeBuildInputs = [
    copyDesktopItems
  ];

  # Install icons.
  postInstall = ''
    install -D -m644 assets/icon/icon_linux.svg $out/share/icons/hicolor/scalable/apps/sideswap.svg
    install -D -m644 assets/icon/icon_linux.png $out/share/icons/hicolor/256x256/apps/sideswap.png
  '';

  # Install .desktop file.
  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Finance"
        "Network"
      ];

      comment = finalAttrs.meta.description;
      desktopName = "SideSwap";
      exec = finalAttrs.meta.mainProgram;
      genericName = "L-USDT Wallet";
      icon = "sideswap";
      name = "sideswap";
      startupNotify = true;
      startupWMClass = "Sideswap";
      terminal = false;
    })
  ];

  # Provide OpenGL and libsideswap_client.so for the Flutter application.
  extraWrapProgramArgs = ''
    --prefix LD_LIBRARY_PATH : ${
      lib.makeLibraryPath [
        libsideswap-client
      ]
    }
  '';

  gitHashes = lib.importJSON ./git-hashes.json;
  pubspecLock = lib.importJSON ./pubspec.lock.json;

  passthru = {
    # Expose lib to access it via sideswap.lib from the update script.
    lib = libsideswap-client;

    pubspecSource =
      runCommand "pubspec.lock.json"
        {
          inherit (finalAttrs) src;
          nativeBuildInputs = [ yq-go ];
        }
        ''
          yq eval --output-format=json --prettyPrint $src/pubspec.lock > "$out"
        '';

    # Usage: nix-shell maintainers/scripts/update.nix --argstr package sideswap
    updateScript = _experimental-update-script-combinators.sequence [
      # Update sideswap to new release.
      (
        (gitUpdater { rev-prefix = "v"; })
        // {
          supportedFeatures = [ ];
        }
      )

      # Update pubspec.lock.json file and related gitHashes attribute.
      (
        (_experimental-update-script-combinators.copyAttrOutputToFile "sideswap.pubspecSource" ./pubspec.lock.json)
        // {
          supportedFeatures = [ ];
        }
      )
      {
        command = [
          dart.fetchGitHashesScript
          "--input"
          ./pubspec.lock.json
          "--output"
          ./git-hashes.json
        ];

        supportedFeatures = [ ];
      }

      # Update libsideswap-client sub-package.
      {
        command = [ ./update-libsideswap-client.sh ];
        supportedFeatures = [ ];
      }
    ];
  };

  meta = {
    description = "Cross‑platform, non‑custodial wallet and atomic swap marketplace for the Liquid Network";
    homepage = "https://sideswap.io/";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ starius ];
    platforms = lib.platforms.linux;
    mainProgram = "sideswap";
  };
})
