{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
  nixosTests,
  trezor-udev-rules,
}:

buildGoModule rec {
  pname = "trezord-go";
  version = "2.0.33";

  src = fetchFromGitHub {
    owner = "trezor";
    repo = "trezord-go";
    tag = "v${version}";
    hash = "sha256-3I6NOzDMhzRyVSOURl7TjJ1Z0P0RcKrSs5rNaZ0Ho9M=";
    fetchSubmodules = true;
  };

  patches = [
    # fix build with Go 1.21 - https://github.com/trezor/trezord-go/pull/300
    (fetchpatch {
      hash = "sha256-yKTwgqWr4L6XEPV85A6D1wpRdpef8hkIbl4LrRmOyuo=";
      url = "https://github.com/trezor/trezord-go/commit/616473d53a8ae49f1099e36ab05a2981a08fa606.patch";
    })
    # fix build with Go 1.24 - https://github.com/trezor/trezord-go/pull/305
    (fetchpatch {
      hash = "sha256-jW+x/FBFEIlRGTDHWF2Oj+05KmFLtFDGJwfYFx7yTv4=";
      url = "https://github.com/trezor/trezord-go/commit/8ca9600d176bebf6cd2ad93ee9525a04059ee735.patch";
    })
  ];

  propagatedBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ trezor-udev-rules ];
  vendorHash = "sha256-wXgAmZEXdM4FcMCQbAs+ydXshCAMu7nl/yVv/3sqaXE=";
  commit = "2680d5e";

  ldflags = [
    "-s"
    "-w"
    "-X main.githash=${commit}"
  ];

  passthru.tests = { inherit (nixosTests) trezord; };

  meta = {
    description = "Trezor Communication Daemon aka Trezor Bridge";
    homepage = "https://trezor.io";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      canndrew
      jb55
      prusnak
      mmahut
      _1000101
    ];

    mainProgram = "trezord-go";
  };
}
