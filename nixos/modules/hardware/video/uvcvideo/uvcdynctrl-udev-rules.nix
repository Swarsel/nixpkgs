{
  buildEnv,
  libwebcam,
  makeWrapper,
  runCommand,
  drivers ? [ ],
  udevDebug ? false,
}:

let
  version = "0.0.0";

  dataPath = buildEnv {
    ignoreCollisions = false;
    name = "uvcdynctrl-with-drivers-data-path";
    paths = drivers ++ [ libwebcam ];
    pathsToLink = [ "/share/uvcdynctrl/data" ];
  };

  dataDir = "${dataPath}/share/uvcdynctrl/data";
  udevDebugVarValue = if udevDebug then "1" else "0";
in

runCommand "uvcdynctrl-udev-rules-${version}"
  {
    inherit dataPath;

    buildInputs = [
      libwebcam
    ];

    dontPatchELF = true;
    dontStrip = true;

    nativeBuildInputs = [
      makeWrapper
    ];

    preferLocalBuild = true;
  }
  ''
    mkdir -p "$out/lib/udev"
    makeWrapper "${libwebcam}/lib/udev/uvcdynctrl" "$out/lib/udev/uvcdynctrl" \
      --set NIX_UVCDYNCTRL_DATA_DIR "${dataDir}" \
      --set NIX_UVCDYNCTRL_UDEV_DEBUG "${udevDebugVarValue}"

    mkdir -p "$out/lib/udev/rules.d"
    cat "${libwebcam}/lib/udev/rules.d/80-uvcdynctrl.rules" | \
      sed -r "s#RUN\+\=\"([^\"]+)\"#RUN\+\=\"$out/lib/udev/uvcdynctrl\"#g" > \
      "$out/lib/udev/rules.d/80-uvcdynctrl.rules"
  ''
