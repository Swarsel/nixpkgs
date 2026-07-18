{
  lib,
  fetchurl,
  autoPatchelfHook,
  gcc,
  installShellFiles,
  libusb1,
  makeWrapper,
  nrfutil,
  segger-jlink-headless,
  stdenvNoCC,
  symlinkJoin,
  versionCheckHook,
  xz,
  zlib,
  extensions ? [ ],
}:

let
  sources = import ./source.nix;
  platformSources =
    sources.${stdenvNoCC.system} or (throw "unsupported platform ${stdenvNoCC.system}");

  sharedMeta = {
    changelog = "https://docs.nordicsemi.com/bundle/nrfutil/page/guides/revision_history.html";
    description = "CLI tool for managing Nordic Semiconductor devices";
    homepage = "https://www.nordicsemi.com/Products/Development-tools/nRF-Util";
    license = lib.licenses.unfree;

    maintainers = with lib.maintainers; [
      h7x4
      ezrizhu
    ];

    platforms = lib.attrNames sources;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };

  packages =
    map
      (
        name:
        let
          package = platformSources.packages.${name};
        in
        stdenvNoCC.mkDerivation (finalAttrs: {
          inherit (package) version;
          pname = name;

          src = fetchurl {
            inherit (package) hash;
            url = "https://files.nordicsemi.com/artifactory/swtools/external/nrfutil/packages/${name}/${name}-${platformSources.triplet}-${package.version}.tar.gz";
          };

          nativeBuildInputs = [
            autoPatchelfHook
          ];

          buildInputs = [
            xz
            zlib
            libusb1
            gcc.cc.lib
            segger-jlink-headless
          ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out
            mv data/* $out/

            runHook postInstall
          '';

          doInstallCheck = true;

          nativeInstallCheckInputs = [
            versionCheckHook
          ];

          dontBuild = true;
          dontConfigure = true;

          meta = sharedMeta // {
            mainProgram = name;
          };
        })
      )
      (
        [
          "nrfutil"
          "nrfutil-completion"
        ]
        ++ extensions
      );

in
symlinkJoin {
  inherit (platformSources.packages.nrfutil) version;
  pname = "nrfutil";

  nativeBuildInputs = [
    makeWrapper
    installShellFiles
  ];

  postBuild =
    let
      wrapProgramArgs = lib.concatStringsSep " " (
        [
          ''--prefix PATH : "$out/bin"''
          ''--prefix PATH : "$out"/lib/nrfutil-npm''
          ''--prefix PATH : "$out"/lib/nrfutil-nrf5sdk-tools''
          "--prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libusb1 ]}"
          "--set NRF_JLINK_DLL_PATH '${segger-jlink-headless}'/lib/libjlinkarm.so"
          ''--set NRFUTIL_BLE_SNIFFER_SHIM_BIN_ENV "$out"/lib/nrfutil-ble-sniffer/wireshark-shim''
          ''--set NRFUTIL_BLE_SNIFFER_HCI_SHIM_BIN_ENV "$out"/lib/nrfutil-ble-sniffer/wireshark-hci-shim''
        ]
        ++ (
          let
            # These are the extensions with the probe-plugin-worker executable vendored.
            relevantExtensions = lib.intersectLists [ "nrfutil-device" "nrfutil-trace" ] extensions;
          in
          lib.optionals (relevantExtensions != [ ]) [
            ''--set NRF_PROBE_PATH "$out"/lib/${lib.head relevantExtensions}''
          ]
        )
      );
    in
    ''
      wrapProgram "$out"/bin/nrfutil ${wrapProgramArgs}

      installShellCompletion --cmd nrfutil \
        --bash $(realpath "$out"/share/nrfutil-completion/scripts/bash/setup.bash) \
        --zsh $(realpath "$out"/share/nrfutil-completion/scripts/zsh/_nrfutil)
    '';

  paths = packages;

  passthru = {
    updateScript = ./update.sh;
    withExtensions = extensions: nrfutil.override { inherit extensions; };
  };

  meta = sharedMeta // {
    mainProgram = "nrfutil";
  };
}
