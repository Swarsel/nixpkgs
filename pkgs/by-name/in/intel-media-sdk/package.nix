{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fetchpatch,
  gtest,
  libdrm,
  libpciaccess,
  libpthread-stubs,
  libva,
  libx11,
  libxau,
  libxdmcp,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "intel-media-sdk";
  version = "23.2.2";

  src = fetchFromGitHub {
    owner = "Intel-Media-SDK";
    repo = "MediaSDK";
    rev = "intel-mediasdk-${version}";
    hash = "sha256-wno3a/ZSKvgHvZiiJ0Gq9GlrEbfHCizkrSiHD6k/Loo=";
  };

  patches = [
    # Search oneVPL-intel-gpu in NixOS specific /run/opengl-driver/lib directory
    # See https://github.com/NixOS/nixpkgs/pull/315425
    ./nixos-search-onevplrt-in-run-opengl-driver-lib.patch
    # https://github.com/Intel-Media-SDK/MediaSDK/pull/3005
    (fetchpatch {
      hash = "sha256-OPwGzcMTctJvHcKn5bHqV8Ivj4P7+E4K9WOKgECqf04=";
      name = "include-cstdint-explicitly.patch";
      url = "https://github.com/Intel-Media-SDK/MediaSDK/commit/a4f37707c1bfdd5612d3de4623ffb2d21e8c1356.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libdrm
    libva
    libpciaccess
    libx11
    libxau
    libxdmcp
    libpthread-stubs
  ];

  cmakeFlags = [
    "-DBUILD_SAMPLES=OFF"
    "-DBUILD_TESTS=OFF"
    "-DUSE_SYSTEM_GTEST=ON"
  ];

  doCheck = false;

  meta = {
    description = "Intel Media SDK";
    homepage = "https://github.com/Intel-Media-SDK/MediaSDK";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      midchildan
      pjungkamp
    ];

    platforms = [ "x86_64-linux" ];
    mainProgram = "mfx-tracer-config";

    knownVulnerabilities = [
      ''
        End of life with various local privilege escalation vulnerabilites:
          - CVE-2023-22656
          - CVE-2023-45221
          - CVE-2023-47169
          - CVE-2023-47282
          - CVE-2023-48368
      ''
    ];
  };
}
