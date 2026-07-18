{
  config,
  lib,
  pkgs,
  ...
}:
let
  hpssacli = pkgs.stdenv.mkDerivation rec {
    dontStrip = true;

    installPhase = ''
      mkdir -p $out/bin $out/share/doc $out/share/man
      mv opt/hp/hpssacli/bld/{hpssascripting,hprmstr,hpssacli} $out/bin/
      mv opt/hp/hpssacli/bld/*.{license,txt}                   $out/share/doc/
      mv usr/man                                               $out/share/

      for file in $out/bin/*; do
        chmod +w $file
        patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                 --set-rpath ${lib.makeLibraryPath [ pkgs.stdenv.cc.cc ]} \
                 $file
      done
    '';

    nativeBuildInputs = [ pkgs.dpkg ];
    pname = "hpssacli";

    src = pkgs.fetchurl {
      sha256 = "11w7fwk93lmfw0yya4jpjwdmgjimqxx6412sqa166g1pz4jil4sw";

      urls = [
        "https://downloads.linux.hpe.com/SDR/downloads/MCP/Ubuntu/pool/non-free/${pname}-${version}_amd64.deb"
        "http://apt.netangels.net/pool/main/h/hpssacli/${pname}-${version}_amd64.deb"
      ];
    };

    unpackPhase = "dpkg -x $src ./";
    version = "2.40-13.0";

    meta = {
      description = "HP Smart Array CLI";
      homepage = "https://downloads.linux.hpe.com/SDR/downloads/MCP/Ubuntu/pool/non-free/";
      license = lib.licenses.unfreeRedistributable;
      maintainers = [ ];
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  ###### interface

  options = {
    hardware.raid.HPSmartArray = {
      enable = lib.mkEnableOption "HP Smart Array kernel modules and CLI utility";
    };
  };

  ###### implementation

  config = lib.mkIf config.hardware.raid.HPSmartArray.enable {

    boot.initrd.availableKernelModules = [ "hpsa" ];
    boot.initrd.kernelModules = [ "sg" ]; # hpssacli wants it
    environment.systemPackages = [ hpssacli ];
  };
}
