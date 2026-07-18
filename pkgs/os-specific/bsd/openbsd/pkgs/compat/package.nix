{ lib, runCommand }:

runCommand "openbsd-compat"
  {
    include = ./include;

    meta = {
      description = "Header-only library for running OpenBSD software on Linux";
      maintainers = with lib.maintainers; [ artemist ];
      platforms = lib.platforms.linux;
    };
  }
  ''
    mkdir -p $out
    cp -R $include $out/include
  ''
