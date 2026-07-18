{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libglvnd,
  libx11,
  libxcursor,
  libxext,
  libxi,
  libxinerama,
  libxrandr,
  libxxf86vm,
  pkg-config,
  withGui ? true,
}:

buildGoModule rec {
  pname = "go2tv" + lib.optionalString (!withGui) "-lite";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "alexballas";
    repo = "go2tv";
    tag = "v${version}";
    hash = "sha256-nAvfWRXPYX5AcJ0S3QXlcOtEEIUQK0FZqSSBNxDtGu4=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    libxcursor
    libxrandr
    libxinerama
    libxi
    libxext
    libxxf86vm
    libglvnd
  ];

  vendorHash = "sha256-vxWvv7PE3VlU2Z9WEAvKiUgJCrK0a6QerMA3Vw+CLZo=";
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-linkmode=external"
  ];

  # conditionally build with GUI or not (go2tv or go2tv-lite sub-packages)
  subPackages = [ "cmd/${pname}" ];

  meta = {
    description = "Cast media files to UPnP/DLNA Media Renderers and Smart TVs";
    homepage = "https://github.com/alexballas/go2tv";
    changelog = "https://github.com/alexballas/go2tv/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ gdamjan ];
    mainProgram = pname;
  };
}
