{
  lib,
  stdenv,
  fetchFromGitHub,
  bison,
  json_c,
  libcap,
  libmnl,
  libsodium,
  libuecc,
  meson,
  ninja,
  openssl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fastd";
  version = "23";

  src = fetchFromGitHub {
    owner = "neocturne";
    repo = "fastd";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-Sz6VEjKziL/w2a4VWFfMPDYvm7UZh5A/NmzP10rJ2r8=";
  };

  nativeBuildInputs = [
    bison
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    json_c
    libcap
    libsodium
    libuecc
    openssl
  ]
  ++ lib.optionals (stdenv.hostPlatform.isLinux) [
    libmnl
  ];

  # some options are only available on x86
  mesonFlags = lib.optionals (!stdenv.hostPlatform.isx86) [
    "-Dcipher_salsa20_xmm=disabled"
    "-Dcipher_salsa2012_xmm=disabled"
    "-Dmac_ghash_pclmulqdq=disabled"
  ];

  meta = {
    description = "Fast and Secure Tunneling Daemon";
    homepage = "https://projects.universe-factory.net/projects/fastd/wiki";

    license = with lib.licenses; [
      bsd2
      bsd3
    ];

    maintainers = with lib.maintainers; [
      fpletz
      herbetom
    ];

    platforms = lib.platforms.linux;
    mainProgram = "fastd";
  };
})
