{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  fontconfig,
  libice,
  libsm,
  libx11,
  lttng-ust_2_12,
  makeDesktopItem,
  makeWrapper,
  openssl,
  zlib,
}:

let
  # These libraries are dynamically loaded by the application,
  # and need to be present in LD_LIBRARY_PATH
  runtimeLibs = [
    fontconfig.lib
    openssl
    (lib.getLib stdenv.cc.cc)
    libx11
    libice
    libsm
    zlib
  ];
in
stdenv.mkDerivation rec {
  pname = "wasabiwallet";
  version = "2.7.1";

  src = fetchurl {
    url = "https://github.com/WalletWasabi/WalletWasabi/releases/download/v${version}/Wasabi-${version}-linux-x64.tar.gz";
    sha256 = "sha256-o2e2NDG2aMrEYc/7x5iFex9oRlrQXeKIINuW80ZwWcI=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = runtimeLibs ++ [
    lttng-ust_2_12
  ];

  installPhase = ''
    mkdir -p $out/opt/${pname} $out/bin $out/share/applications

    # The weird path is an upstream packaging error and could be fixed in the upcoming release
    cp -Rv ./runner/work/WalletWasabi/WalletWasabi/build/linux-x64/* $out/opt/${pname}

    for nameMap in "wassabee:desktop" "wassabeed:daemon" "wcoordinator:coordinator" "wbackend:backend"; do
      IFS=":" read -r filename wrappedname <<< "$nameMap"
      makeWrapper "$out/opt/${pname}/$filename" "$out/bin/${pname}-$wrappedname" \
        --suffix "LD_LIBRARY_PATH" : "${lib.makeLibraryPath runtimeLibs}"
    done

    cp -v $desktopItem/share/applications/* $out/share/applications
  '';

  desktopItem = makeDesktopItem {
    categories = [
      "Network"
      "Utility"
    ];

    comment = meta.description;
    desktopName = "Wasabi";
    exec = "wasabiwallet-desktop";
    genericName = "Bitcoin wallet";
    name = "wasabi";
  };

  dontBuild = true;

  meta = {
    description = "Privacy focused Bitcoin wallet";
    homepage = "https://wasabiwallet.io/";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ mmahut ];
    platforms = [ "x86_64-linux" ];
  };
}
