{
  lib,
  stdenv,
  expat,
  fetchCrate,
  fontconfig,
  libGL,
  libgit2,
  libx11,
  libxcb,
  libxcursor,
  libxi,
  libxrandr,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cargo-ui";
  version = "0.3.3";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-M/ljgtTHMSc7rY/a8CpKGNuOSdVDwRt6+tzPPHdpKOw=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libgit2
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    expat
    fontconfig
    libGL
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
  ];

  cargoHash = "sha256-odcyKOveYCWQ35uh//s19Jtq7OqiUnkeqbh90VWHp9A=";

  env = {
    LIBGIT2_NO_VENDOR = 1;
  };

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    patchelf $out/bin/cargo-ui \
      --add-rpath ${
        lib.makeLibraryPath [
          fontconfig
          libGL
        ]
      }
  '';

  meta = {
    description = "GUI for Cargo";
    homepage = "https://github.com/slint-ui/cargo-ui";
    changelog = "https://github.com/slint-ui/cargo-ui/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      mit
      asl20
      gpl3Only
    ];

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    mainProgram = "cargo-ui";
  };
})
