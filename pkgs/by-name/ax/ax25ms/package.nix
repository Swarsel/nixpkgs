{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  grpc,
  libax25,
  libtool,
  pkg-config,
  protobuf,
  which,
}:

stdenv.mkDerivation {
  pname = "ax25ms";
  version = "0-unstable-2024-04-28";

  src = fetchFromGitHub {
    owner = "ThomasHabets";
    repo = "ax25ms";
    rev = "c7d7213bb182e4b60f655c3f9f1bcb2b2440406b";
    hash = "sha256-GljGJa44topJ6T0g5wuU8GTHLKzNmQqUl8/AR+pw2+I=";
  };

  nativeBuildInputs = [
    which
    pkg-config
    autoconf
    libtool
    automake
  ];

  buildInputs = [
    protobuf
    grpc
    libax25
  ];

  preConfigure = ''
    patchShebangs scripts
    ./bootstrap.sh
  '';

  postInstall = ''
    set +e
    for binary_path in "$out/bin"/*; do
      filename=$(basename "$binary_path")
      mv "$binary_path" "$out/bin/ax25ms-$filename"
    done
    set -e
  '';

  meta = {
    description = "Set of AX.25 microservices, designed to be pluggable for any implementation";
    homepage = "https://github.com/ThomasHabets/ax25ms";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      matthewcroughan
      sarcasticadmin
      pkharvey
    ];

    platforms = lib.platforms.all;
  };
}
