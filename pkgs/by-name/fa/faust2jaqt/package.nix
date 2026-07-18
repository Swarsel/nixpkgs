{
  alsa-lib,
  bash,
  buildPackages,
  faust,
  jack2,
  libsndfile,
  qt5,
  which,
  writeText,
}:
let
  # Wrap the binary coming out of the the compilation script, so it knows QT_PLUGIN_PATH
  wrapBinary = writeText "wrapBinary" ''
    source ${buildPackages.makeWrapper}/nix-support/setup-hook
    for p in $FILES; do
      workpath=$PWD
      cd -- "$(dirname "$p")"
      binary=$(basename --suffix=.dsp "$p")
      rm -f .$binary-wrapped
      wrapProgram $binary --set QT_PLUGIN_PATH "${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}"
      sed -i $binary -e 's@exec@cd "$(dirname "$(readlink -f "''${BASH_SOURCE[0]}")")" \&\& exec@g'
      cd $workpath
    done
  '';
in
faust.wrapWithBuildEnv {

  buildInputs = [
    bash
  ];

  propagatedBuildInputs = [
    jack2
    qt5.qtbase
    libsndfile
    alsa-lib
    which
  ];

  preFixup = ''
    for script in "$out"/bin/*; do
      # append the wrapping code to the compilation script
      cat ${wrapBinary} >> $script
      # prevent the qmake error when running the script
      sed -i "/QMAKE=/c\ QMAKE="${qt5.qtbase.dev}/bin/qmake"" $script
    done
  '';

  baseName = "faust2jaqt";
  dontWrapQtApps = true;

  scripts = [
    "faust2jaqt"
    "faust2jackserver"
  ];
}
