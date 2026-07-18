{
  lib,
  stdenv,
  fetchurl,
  unzip,
}:

let
  bits = if stdenv.hostPlatform.is64bit then "x64" else "ia32";
  version = "0.107.0";
in
stdenv.mkDerivation {
  inherit version;
  pname = "nwjs-ffmpeg-prebuilt";

  src =
    let
      hashes = {
        "ia32" = "sha256-j5Kxr8ne2l2JbXOvAsJoluKoh3rgWuxqX+L8w0+1kXk=";
        "x64" = "sha256-j5Kxr8ne2l2JbXOvAsJoluKoh3rgWuxqX+L8w0+1kXk=";
      };
    in
    fetchurl {
      url = "https://github.com/nwjs-ffmpeg-prebuilt/nwjs-ffmpeg-prebuilt/releases/download/${version}/${version}-linux-${bits}.zip";
      hash = hashes.${bits};
    };

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    cp -R libffmpeg.so $out/lib/

    runHook postInstall
  '';

  sourceRoot = ".";

  meta = {
    description = "App runtime based on Chromium and node.js";
    homepage = "https://nwjs.io/";
    license = lib.licenses.gpl2Plus;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];

    maintainers = with lib.maintainers; [
      ilya-epifanov
      mikaelfangel
    ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];
  };
}
