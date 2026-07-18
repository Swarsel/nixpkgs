{
  lib,
  stdenv,
  fetchurl,
  callPackage,
  common-updater-scripts,
  curl,
  jq,
  writeShellScript,
}:
let
  pname = "proton-pass";
  version = "1.38.0";

  passthru = {
    sources = {
      "aarch64-darwin" = fetchurl {
        hash = "sha256-CwdiHEqKnk+ELoavs1p6ND48e2rvEFBqbXQs79ihQ4M=";
        url = "https://proton.me/download/pass/macos/ProtonPass_${version}.dmg";
      };

      "x86_64-linux" = fetchurl {
        hash = "sha256-6WYiqEJquq64b1fNv8HcQcT4/VCwtEkK4YrfAXDC6nY=";
        url = "https://proton.me/download/pass/linux/x64/proton-pass_${version}_amd64.deb";
      };
    };

    updateScript = writeShellScript "update-proton-pass" ''
      set -o errexit
      export PATH="${
        lib.makeBinPath [
          curl
          jq
          common-updater-scripts
        ]
      }"
      NEW_VERSION=$(curl --silent https://proton.me/download/PassDesktop/linux/x64/version.json | jq -r '[.Releases[] | select(.CategoryName == "Stable")] | first | .Version')
      if [[ "${version}" = "$NEW_VERSION" ]]; then
          echo "The new version is the same as the old version."
          exit 0
      fi
      for platform in ${lib.escapeShellArgs meta.platforms}; do
        update-source-version "proton-pass" "$NEW_VERSION" --ignore-same-version --source-key="sources.$platform"
      done
    '';
  };

  meta = {
    description = "Desktop application for Proton Pass";
    homepage = "https://proton.me/pass";
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      luftmensch-luftmensch
      massimogengarelli
      shunueda
    ];

    platforms = builtins.attrNames passthru.sources;
    mainProgram = "proton-pass";
  };
in
callPackage (if stdenv.hostPlatform.isDarwin then ./darwin.nix else ./linux.nix) {
  inherit
    pname
    version
    passthru
    meta
    ;
}
