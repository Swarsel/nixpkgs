{
  lib,
  brscan5,
  stdenv,
  netDevices ? [ ],
}:

/*
  Testing
  -------
  From nixpkgs repo

  No net devices:

  ~~~
  nix-build -E 'let pkgs = import ./. {};
                    brscan5-etc-files = pkgs.callPackage (import ./nixos/modules/services/hardware/sane_extra_backends/brscan5_etc_files.nix) {};
                in brscan5-etc-files'
  ~~~

  Two net devices:

  ~~~
  nix-build -E 'let pkgs = import ./. {};
                    brscan5-etc-files = pkgs.callPackage (import ./nixos/modules/services/hardware/sane_extra_backends/brscan5_etc_files.nix) {};
                in brscan5-etc-files.override {
                     netDevices = [
                       {name="a"; model="ADS-1200"; nodename="BRW0080927AFBCE";}
                       {name="b"; model="ADS-1200"; ip="192.168.1.2";}
                     ];
                }'
  ~~~
*/

let

  addNetDev = nd: ''
    brsaneconfig5 -a \
    name="${nd.name}" \
    model="${nd.model}" \
    ${
      if (lib.hasAttr "nodename" nd && nd.nodename != null) then
        ''nodename="${nd.nodename}"''
      else
        ''ip="${nd.ip}"''
    }'';
  addAllNetDev = xs: lib.concatStringsSep "\n" (map addNetDev xs);
in

stdenv.mkDerivation {

  buildPhase = ''
    TARGET_DIR="$out/etc/opt/brother/scanner/brscan5"
    mkdir -p "$TARGET_DIR"
    cp -rp "./models" "$TARGET_DIR"
    cp -rp "./brscan5.ini" "$TARGET_DIR"
    cp -rp "./brsanenetdevice.cfg" "$TARGET_DIR"

    export NIX_REDIRECTS="/etc/opt/brother/scanner/brscan5/=$TARGET_DIR/"

    printf '${addAllNetDev netDevices}\n'

    ${addAllNetDev netDevices}
  '';

  dontConfigure = true;
  dontInstall = true;
  name = "brscan5-etc-files";
  nativeBuildInputs = [ brscan5 ];
  src = "${brscan5}/opt/brother/scanner/brscan5";
  version = "1.2.6-0";

  meta = {
    description = "Brother brscan5 sane backend driver etc files";
    homepage = "https://www.brother.com";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ mattchrist ];
    platforms = lib.platforms.linux;
  };
}
