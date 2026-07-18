{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "zfsbackup";
  version = "unstable-2022-09-23";

  src = fetchFromGitHub {
    inherit rev;
    owner = "someone1";
    repo = "zfsbackup-go";
    sha256 = "sha256-ZJ7gtT4AdMLEs2+hJa2Sia0hSoQd3CftdqRsH/oJxd8=";
  };

  vendorHash = "sha256-aYAficUFYYhZygfQZyczP49CeouAKKZJW8IFlkFh9lI=";
  # Tests require loading the zfs kernel module.
  doCheck = false;

  ldflags = [
    "-w"
    "-s"
  ];

  rev = "a30f1a44bcae5f64cfb36a12926242a968a759c6";

  meta = {
    description = "Backup ZFS snapshots to cloud storage such as Google, Amazon, Azure, etc";
    homepage = "https://github.com/someone1/zfsbackup-go";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "zfsbackup-go";
  };
}
