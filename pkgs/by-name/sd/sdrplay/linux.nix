{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  libusb1,
  meta,
  pname,
  src,
  udev,
  version,
}:
let
  arch = stdenv.hostPlatform.qemuArch;
in
stdenv.mkDerivation rec {
  inherit
    pname
    version
    src
    meta
    ;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    libusb1
    udev
    (lib.getLib stdenv.cc.cc)
  ];

  env = {
    majorMinorVersion = lib.versions.majorMinor version;
    majorVersion = lib.versions.major version;
  };

  installPhase = ''
    mkdir -p $out/{bin,lib,include,lib/udev/rules.d}
    libName="libsdrplay_api"
    cp "${arch}/$libName.so.$majorMinorVersion" $out/lib/
    ln -s "$out/lib/$libName.so.$majorMinorVersion" "$out/lib/$libName.so.$majorVersion"
    ln -s "$out/lib/$libName.so.$majorVersion" "$out/lib/$libName.so"
    cp "${arch}/sdrplay_apiService" $out/bin/
    cp -r inc/* $out/include/
    awk 'index($0, "cat > /etc/udev/rules.d/66-sdrplay.rules"){flag=1; next} /EOF/{flag=0} flag' install_lib.sh > $out/lib/udev/rules.d/66-sdrplay.rules
  '';

  dontBuild = true;
  sourceRoot = "source";

  unpackPhase = ''
    sh "$src" --noexec --target source
  '';
}
