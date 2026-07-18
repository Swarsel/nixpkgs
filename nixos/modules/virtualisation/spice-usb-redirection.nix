{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.virtualisation.spiceUSBRedirection.enable = lib.mkOption {
    default = false;

    description = ''
      Install the SPICE USB redirection helper with setuid
      privileges. This allows unprivileged users to pass USB devices
      connected to this machine to libvirt VMs, both local and
      remote. Note that this allows users arbitrary access to USB
      devices.
    '';

    type = lib.types.bool;
  };

  config = lib.mkIf config.virtualisation.spiceUSBRedirection.enable {
    environment.systemPackages = [ pkgs.spice-gtk ]; # For polkit actions

    security.wrappers.spice-client-glib-usb-acl-helper = {
      capabilities = "cap_fowner+ep";
      group = "root";
      owner = "root";
      source = "${pkgs.spice-gtk}/bin/spice-client-glib-usb-acl-helper";
    };
  };

  meta.maintainers = [ ];
}
