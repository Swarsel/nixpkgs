{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
  go-bindata,
  ipxe,
  perl,
  xz,
}:

let
  rebuildIpxe = stdenv.system == "x86_64-linux";
in
buildGoModule rec {
  pname = "pixiecore";
  version = "0-unstable-2024-05-31";

  src = fetchFromGitHub {
    inherit rev;
    owner = "danderson";
    repo = "netboot";
    hash = "sha256-pG4nzzJRWI1rAHS5kBcefNi0ee0/a3jwE+RmR4Dj8jo=";
  };

  patches = [
    # part of https://github.com/danderson/netboot/pull/144
    # Also backed up in https://github.com/danderson/netboot/compare/main...Mic92:netboot:upgrade-go-mod-117?expand=1
    (fetchpatch {
      sha256 = "sha256-pRWcBz24cqqajLvJffugB/T6lKGVtvOG4ch3vyzDDQQ=";
      url = "https://github.com/danderson/netboot/commit/c999a6ca573c973e760c8df531b4c970c21f3d05.patch";
    })
  ];

  nativeBuildInputs = lib.optionals rebuildIpxe [
    perl
    go-bindata
  ];

  # De-vendor ipxe, only on x86_64-linux for now.
  # In future we can do this also for more systems, if we do cross-compilation.
  buildInputs = lib.optionals rebuildIpxe [ xz ];
  vendorHash = "sha256-3cVGDAZWhmZ1byvjoRodSWMNHCpNujDOAVQKHNntHR8=";
  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-error" ];

  preBuild = lib.optionalString rebuildIpxe ''
    # don't run in our go-modules phase but only in the normal build phase
    if echo $NIX_CFLAGS_COMPILE | grep -q xz; then
      rm -rf ./third_party/ipxe
      cp -r ${ipxe.src} ./third_party/ipxe
      chmod -R u+w ./third_party/ipxe
      make update-ipxe -j$NIX_BUILD_CORES
    fi
  '';

  doCheck = false;
  rev = "2ed7bd30206a51bae786b02d9a5b8156fdcc8870";
  subPackages = [ "cmd/pixiecore" ];

  meta = {
    description = "Tool to manage network booting of machines";
    homepage = "https://github.com/danderson/netboot/tree/master/pixiecore";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      bbigras
      mic92
    ];

    mainProgram = "pixiecore";
  };
}
