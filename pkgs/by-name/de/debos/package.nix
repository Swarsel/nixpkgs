{
  lib,
  fetchFromGitHub,
  buildGoModule,
  dpkg,
  glib,
  nix-update-script,
  ostree,
  pkg-config,
  qemu,
  unzip,
}:

buildGoModule (finalAttrs: {
  pname = "debos";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "go-debos";
    repo = "debos";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Bu0rLrRp1oeWSMm78DhNM6MsBeG+vAkoRbbqKTThD/8=";
  };

  nativeBuildInputs = [
    dpkg
    pkg-config
    unzip
  ];

  buildInputs = [
    glib
    ostree
    qemu
  ];

  vendorHash = "sha256-+3PAqCOFtR8HC4uNNxH1cKk/qkD13zuydTsZte1mQ+c=";

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool to create Debian OS images";
    homepage = "https://github.com/go-debos/debos";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "debos";
  };
})
