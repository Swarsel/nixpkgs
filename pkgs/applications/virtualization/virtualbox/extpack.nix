{
  lib,
  fetchurl,
  virtualbox,
}:
fetchurl rec {
  pname = "virtualbox-extpack";
  version = "7.2.10";
  name = "Oracle_VirtualBox_Extension_Pack-${version}.vbox-extpack";

  sha256 =
    # Manually sha256sum the extensionPack file, must be hex!
    # Thus do not use `nix-prefetch-url` but instead plain old `sha256sum`.
    # Checksums can also be found at https://download.virtualbox.org/virtualbox/${version}/SHA256SUMS
    let
      value = "87f03161e5b6b1ecfa0024f795eefdb68abc46aa9689f67bb69e7db4ef9033dd";
    in
    assert (builtins.stringLength value) == 64;
    value;

  url = "https://download.virtualbox.org/virtualbox/${version}/${name}";

  meta = {
    description = "Oracle Extension pack for VirtualBox";
    homepage = "https://www.virtualbox.org/";
    license = lib.licenses.virtualbox-puel;

    maintainers = with lib.maintainers; [
      friedrichaltheide
    ];

    platforms = [ "x86_64-linux" ];
  };
}
