{
  fetchurl,
  appimageTools,
  lndir,
  pname,
  sha256,
  version,
  metaCommon ? { },
}:

let
  src = fetchurl {
    inherit sha256;
    url = "https://github.com/sindresorhus/caprine/releases/download/v${version}/Caprine-${version}.AppImage";
    name = "Caprine-${version}.AppImage";
  };
  extracted = appimageTools.extractType2 { inherit pname version src; };
in
(appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mkdir -p $out/share
    "${lndir}/bin/lndir" -silent "${extracted}/usr/share" "$out/share"
    ln -s ${extracted}/caprine.png $out/share/icons/caprine.png
    mkdir $out/share/applications
    cp ${extracted}/caprine.desktop $out/share/applications/
    substituteInPlace $out/share/applications/caprine.desktop \
        --replace AppRun caprine
  '';

  profile = ''
    export LC_ALL=C.UTF-8
  '';

  passthru = {
    inherit pname version src;
  };

  meta = metaCommon // {
    platforms = [ "x86_64-linux" ];
  };
})
