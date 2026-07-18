{
  fetchurl,
  appimageTools,
  hash,
  makeWrapper,
  pname,
  version,
  metaCommon ? { },
}:

let
  src = fetchurl {
    inherit hash;
    url = "https://github.com/mifi/lossless-cut/releases/download/v${version}/LosslessCut-linux-x86_64.AppImage";
  };

  extracted = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;
  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands = ''
    (
      mkdir -p $out/share
      cd ${extracted}/usr
      find share -mindepth 1 -type d -exec mkdir -p $out/{} \;
      find share -mindepth 1 -type f,l -exec ln -s $PWD/{} $out/{} \;
    )
    ln -s ${extracted}/losslesscut.png $out/share/icons/losslesscut.png
    mkdir $out/share/applications
    cp ${extracted}/losslesscut.desktop $out/share/applications
    substituteInPlace $out/share/applications/losslesscut.desktop \
      --replace AppRun losslesscut
    wrapProgram "$out/bin/losslesscut" \
      --add-flags "--disable-seccomp-filter-sandbox"
  '';

  profile = ''
    export LC_ALL=C.UTF-8
  '';

  meta = metaCommon // {
    platforms = [ "x86_64-linux" ];
    mainProgram = "losslesscut";
  };
}
