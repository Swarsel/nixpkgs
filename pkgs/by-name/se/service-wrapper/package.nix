{
  lib,
  stdenv,
  coreutils,
  replaceVarsWith,
  runCommand,
}:

let
  pname = "service-wrapper";
  version = "19.04"; # Akin to Ubuntu Release
in
runCommand "${pname}-${version}"
  {
    inherit pname version;

    script = replaceVarsWith {
      src = ./service-wrapper.sh;
      isExecutable = true;

      replacements = {
        inherit (stdenv) shell;
        inherit coreutils;
      };
    };

    meta = {
      description = "Convenient wrapper for the systemctl commands, borrow from Ubuntu";
      license = lib.licenses.gpl2Plus;
      maintainers = with lib.maintainers; [ DerTim1 ];
      platforms = lib.platforms.linux;
      mainProgram = "service";
      # Shellscript has been modified but upstream source is: https://git.launchpad.net/ubuntu/+source/init-system-helpers
    };
  }
  ''
    mkdir -p $out/bin
    ln -s $out/bin $out/sbin
    cp $script $out/bin/service
    chmod a+x $out/bin/service
  ''
