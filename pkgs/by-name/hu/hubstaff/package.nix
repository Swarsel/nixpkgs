{
  lib,
  stdenv,
  fetchurl,
  cairo,
  common-updater-scripts,
  copyDesktopItems,
  curl,
  fontconfig,
  freetype,
  glib,
  gtk3,
  libappindicator-gtk3,
  libice,
  libnotify,
  libsm,
  libx11,
  libxcursor,
  libxext,
  libxfixes,
  libxft,
  libxinerama,
  libxrender,
  libxscrnsaver,
  makeDesktopItem,
  makeWrapper,
  unzip,
  writeShellScript,
  xmlstarlet,
  zlib,
}:

let
  url = "https://app.hubstaff.com/download/11100-standard-linux-1-7-8-release/sh";
  version = "1.7.8-c835b2c2";
  sha256 = "sha256:0cv6b5rx1bjizwa22xlzmljwgcvm1mqyng79qqrdzmd0xy7c02pi";

  rpath = lib.makeLibraryPath [
    libx11
    zlib
    libsm
    libice
    libxext
    freetype
    libxrender
    fontconfig
    libxft
    libxinerama
    stdenv.cc.cc
    libnotify
    glib
    gtk3
    libappindicator-gtk3
    curl
    libxfixes
    libxscrnsaver
    libxcursor
    cairo
  ];

in

stdenv.mkDerivation {
  inherit version;
  pname = "hubstaff";
  src = fetchurl { inherit sha256 url; };

  nativeBuildInputs = [
    unzip
    makeWrapper
    copyDesktopItems
  ];

  installPhase = ''
    runHook preInstall
    # remove files for 32-bit arch to skip building for this arch
    # but add -f flag to not fail if files were not found (new versions dont provide 32-bit arch)
    rm -rf x86 x86_64/lib64

    opt=$out/opt/hubstaff
    mkdir -p $out/bin $opt
    cp -r . $opt/

    for f in "$opt/x86_64/"*.bin.x86_64 ; do
      patchelf --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) $f
      wrapProgram $f --prefix LD_LIBRARY_PATH : ${rpath}
    done

    ln -s $opt/x86_64/HubstaffClient.bin.x86_64 $out/bin/HubstaffClient
    ln -s $opt/x86_64/HubstaffCLI.bin.x86_64 $out/bin/HubstaffCLI

    # Why is this needed? SEGV otherwise.
    ln -s $opt/data/resources $opt/x86_64/resources

    # Link icons to the standard directory
    for dir in $opt/data/resources/hicolor/[0-9]*x[0-9]*; do
      size=$(basename "$dir")
      mkdir -p $out/share/icons/hicolor/$size/apps
      ln -s $dir/apps/hubstaff-color.png $out/share/icons/hicolor/$size/apps/hubstaff-color.png
    done
    runHook postInstall
  '';

  # Upstream doesn't seem to have a desktop item out of the box
  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Office"
        "ProjectManagement"
      ];

      comment = "Time tracking software";
      desktopName = "Hubstaff";
      exec = "HubstaffClient";
      icon = "hubstaff-color";
      name = "netsoft-com.netsoft.hubstaff";
    })
  ];

  dontBuild = true;

  unpackCmd = ''
    # MojoSetups have a ZIP file at the end. ZIP’s magic string is
    # most often PK\x03\x04. This has worked for all past updates,
    # but feel free to come up with something more reasonable.
    dataZipOffset=$(grep --max-count=1 --byte-offset --only-matching --text ''$'PK\x03\x04' $curSrc | cut -d: -f1)
    dd bs=$dataZipOffset skip=1 if=$curSrc of=data.zip 2>/dev/null
    unzip -q data.zip "data/*"
    rm data.zip
  '';

  # to test run:
  # nix-shell maintainers/scripts/update.nix --argstr package hubstaff
  # nix-build -A pkgs.hubstaff
  passthru.updateScript = writeShellScript "hubstaff-updater" ''
    set -eu -o pipefail

    # Create a temporary file
    temp_file=$(mktemp)

    # Fetch the appcast.xml and save it to the temporary file
    curl --silent --output "$temp_file" https://app.hubstaff.com/appcast.xml

    # Extract the latest release URL for Linux using xmlstarlet
    installation_script_url=$(${xmlstarlet}/bin/xmlstarlet sel -t -v '//enclosure[@sparkle:os="linux"]/@url' "$temp_file")
    version=$(${xmlstarlet}/bin/xmlstarlet sel -t -v '//enclosure[@sparkle:os="linux"]/@sparkle:version' "$temp_file")

    sha256=$(nix-prefetch-url "$installation_script_url")

    ${common-updater-scripts}/bin/update-source-version hubstaff "$version" "sha256:$sha256" "$installation_script_url"
  '';

  meta = {
    description = "Time tracking software";
    homepage = "https://hubstaff.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      michalrus
    ];

    platforms = [ "x86_64-linux" ];
  };
}
