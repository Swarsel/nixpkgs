{ lib, ... }:

{
  imports = [
    ./lxc-image-metadata.nix

    ../installer/cd-dvd/channel.nix
    ../profiles/clone-config.nix
    ../profiles/minimal.nix
  ];

  # friendlier defaults than minimal profile provides
  # but we can't use mkDefault since minimal uses it
  documentation.enable = lib.mkOverride 890 true;
  documentation.nixos.enable = lib.mkOverride 890 true;

  # Some more help text.
  services.getty.helpLine = ''

    Log in as "root" with an empty password.
  '';

  services.logrotate.enable = true;
  # Containers should be light-weight, so start sshd on demand.
  services.openssh.enable = lib.mkDefault true;
  services.openssh.startWhenNeeded = lib.mkDefault true;
  # Allow the user to login as root without password.
  users.users.root.initialHashedPassword = lib.mkOverride 150 "";

  meta = {
    teams = [ lib.teams.lxc ];
  };
}
