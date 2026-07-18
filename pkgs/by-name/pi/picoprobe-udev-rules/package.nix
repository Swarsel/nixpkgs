{
  lib,
  stdenv,
  fetchurl,
  udevCheckHook,
}:

## Usage
# In NixOS, simply add this package to services.udev.packages:
#   services.udev.packages = [ pkgs.picoprobe-udev-rules ];

stdenv.mkDerivation {
  pname = "picoprobe-udev-rules";
  version = "unstable-2023-01-31";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/probe-rs/webpage/1cba61acc6ecb5ff96f74641269844ad88ad8ad5/static/files/69-probe-rs.rules";
    sha256 = "sha256-vQMPX3Amttja0u03KWGnPDAVTGM9ekJ+IBTjW+xlJS0=";
  };

  nativeBuildInputs = [
    udevCheckHook
  ];

  installPhase = ''
    runHook preInstall
    install -D $src $out/lib/udev/rules.d/69-probe-rs.rules
    runHook postInstall
  '';

  doInstallCheck = true;
  dontBuild = true;
  dontUnpack = true;

  meta = {
    description = "Picoprobe udev rules list";
    homepage = "https://probe.rs/docs/getting-started/probe-setup/#udev-rules";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.linux;
  };
}
