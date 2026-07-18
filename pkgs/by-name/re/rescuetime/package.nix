{
  lib,
  stdenv,
  fetchurl,
  common-updater-scripts,
  curl,
  dpkg,
  libx11,
  libxext,
  libxscrnsaver,
  libxtst,
  patchelf,
  pup,
  qt5,
  writeScript,
}:

let
  version = "2.16.5.1";
  src =
    if stdenv.hostPlatform.system == "i686-linux" then
      fetchurl {
        url = "https://www.rescuetime.com/installers/rescuetime_${version}_i386.deb";
        sha256 = "1xrvyy0higc1fbc8ascpaszvg2bl6x0a35bzmdq6dkay48hnrd8b";
        name = "rescuetime-installer.deb";
      }
    else
      fetchurl {
        url = "https://www.rescuetime.com/installers/rescuetime_${version}_amd64.deb";
        sha256 = "09ng0yal66d533vzfv27k9l2va03rqbqmsni43qi3hgx7w9wx5ii";
        name = "rescuetime-installer.deb";
      };
in
stdenv.mkDerivation rec {
  # https://www.rescuetime.com/updates/linux_release_notes.html
  inherit version;
  inherit src;
  pname = "rescuetime";

  nativeBuildInputs = [
    dpkg
    qt5.wrapQtAppsHook
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp usr/bin/rescuetime $out/bin

    ${patchelf}/bin/patchelf \
      --interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      --set-rpath "${
        lib.makeLibraryPath [
          qt5.qtbase
          libxtst
          libxext
          libx11
          libxscrnsaver
        ]
      }" \
      $out/bin/rescuetime
  '';

  # avoid https://github.com/NixOS/patchelf/issues/99
  dontStrip = true;

  passthru.updateScript = writeScript "${pname}-updater" ''
    #!${stdenv.shell}
    set -eu -o pipefail
    PATH=${
      lib.makeBinPath [
        curl
        pup
        common-updater-scripts
      ]
    }:$PATH
    latestVersion="$(curl -sS https://www.rescuetime.com/release-notes/linux | pup '.release:first-of-type h2 strong text{}' | tr -d '\n')"

    for platform in ${lib.concatStringsSep " " meta.platforms}; do
      update-source-version ${pname} "$latestVersion" --system=$platform --ignore-same-version
    done
  '';

  meta = {
    description = "Helps you understand your daily habits so you can focus and be more productive";
    homepage = "https://www.rescuetime.com";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
