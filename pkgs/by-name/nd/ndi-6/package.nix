{
  lib,
  stdenv,
  fetchurl,
  avahi,
  ffmpeg_7,
  obs-studio-plugins,
}:

let
  versionJSON = lib.importJSON ./version.json;
  ndiPlatform =
    if stdenv.hostPlatform.isAarch64 then
      "aarch64-rpi4-linux-gnueabi"
    else if stdenv.hostPlatform.isAarch32 then
      "arm-rpi2-linux-gnueabihf"
    else if stdenv.hostPlatform.isx86_64 then
      "x86_64-linux-gnu"
    else
      throw "unsupported platform for NDI SDK";
in
stdenv.mkDerivation rec {
  pname = "ndi-6";
  version = versionJSON.version;

  src = fetchurl {
    url = "https://downloads.ndi.tv/SDK/NDI_SDK_Linux/${installerName}.tar.gz";
    hash = versionJSON.hash;
  };

  installPhase = ''
    mkdir -p $out $out/share/doc/ndi-6
    mv bin/${ndiPlatform} $out/bin
    mv lib/${ndiPlatform} $out/lib
    # Fake ndi version 5 for compatibility with DistroAV (obs plugin using NDI)
    ln -s $out/lib/libndi.so $out/bin/libndi.so.5
    mv include examples $out/
    mv licenses $out/share/doc/ndi-6/licenses
    mv documentation/* $out/share/doc/ndi-6/
  '';

  dontPatchELF = true;
  # Stripping breaks ndi-record.
  dontStrip = true;

  fixupPhase = ''
    for i in $out/bin/*; do
      if [ -L "$i" ]; then continue; fi
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" "$i"
      patchelf --set-rpath "${avahi}/lib:${ffmpeg_7.lib}/lib:${stdenv.cc.libc}/lib" "$i"
    done
    for i in $out/lib/*; do
      if [ -L "$i" ]; then continue; fi
      patchelf --set-rpath "${avahi}/lib:${ffmpeg_7.lib}/lib:${stdenv.cc.libc}/lib" "$i"
    done
  '';

  installerName = "Install_NDI_SDK_v${majorVersion}_Linux";
  majorVersion = lib.versions.major version;

  unpackPhase = ''
    unpackFile $src
    echo y | ./${installerName}.sh
    sourceRoot="NDI SDK for Linux";
  '';

  passthru.tests = {
    inherit (obs-studio-plugins) distroav;
  };

  passthru.updateScript = ./update.py;

  meta = {
    description = "NDI Software Developer Kit";
    homepage = "https://ndi.video/ndi-sdk/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];

    maintainers = with lib.maintainers; [
      globule655
      ChaosAttractor
    ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
      "aarch64-linux"
      "armv7l-linux"
    ];
  };
}
