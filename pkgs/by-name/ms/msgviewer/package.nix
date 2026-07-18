{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
  runtimeShell,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "msgviewer";
  version = "1.9";

  src = fetchurl {
    url = "mirror://sourceforge/msgviewer/${uname}-${version}/${uname}-${version}.zip";
    sha256 = "0igmr8c0757xsc94xlv2470zv2mz57zaj52dwr9wj8agmj23jbjz";
  };

  nativeBuildInputs = [
    makeWrapper
    unzip
  ];

  buildCommand = ''
    dir=$out/lib/msgviewer
    mkdir -p $out/bin $dir
    unzip $src -d $dir
    mv $dir/${uname}-${version}/* $dir
    rmdir $dir/${uname}-${version}
    cat <<_EOF > $out/bin/msgviewer
    #!${runtimeShell} -eu
    exec ${lib.getBin jre}/bin/java -jar $dir/MSGViewer.jar "\$@"
    _EOF
    chmod 755 $out/bin/msgviewer
  '';

  uname = "MSGViewer";

  meta = {
    description = "Viewer for .msg files (MS Outlook)";
    homepage = "https://www.washington.edu/alpine/";
    license = lib.licenses.asl20;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ peterhoeg ];
    platforms = lib.platforms.all;
    mainProgram = "msgviewer";
  };
}
