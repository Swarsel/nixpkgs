{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  go,
  # Linux specific dependencies
  gtk3,
  makeWrapper,
  nix-update-script,
  nodejs,
  pkg-config,
  webkitgtk_4_1,
  zlib,
}:

buildGoModule (finalAttrs: {
  pname = "wails";
  version = "2.12.0";

  src = fetchFromGitHub {
    owner = "wailsapp";
    repo = "wails";
    tag = "v${finalAttrs.version}";
    hash = "sha256-XngfbEbXhPRRKbNp/aaVCleISABTs90d5JjmwIq7nsk=";
  };

  # These packages are needed to build wails
  # and will also need to be used when building a wails app.
  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  # Following packages are required when wails used as a builder.
  propagatedBuildInputs = [
    pkg-config
    go
    stdenv.cc
    nodejs
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    gtk3
    webkitgtk_4_1
  ];

  vendorHash = "sha256-dmSH5I+bOErmtCxQdjkJXp1x2G5bpElL1VK6aZOv69I=";

  # As Wails calls a compiler, certain apps and libraries need to be made available.
  postFixup = ''
    wrapProgram $out/bin/wails \
      --suffix PATH : ${
        lib.makeBinPath [
          pkg-config
          go
          stdenv.cc
          nodejs
        ]
      } \
      --suffix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath (
          lib.optionals stdenv.hostPlatform.isLinux [
            gtk3
            webkitgtk_4_1
          ]
        )
      }" \
      --set PKG_CONFIG_PATH "$PKG_CONFIG_PATH" \
      --set CGO_LDFLAGS "-L${lib.makeLibraryPath [ zlib ]}"
  '';

  # Wails apps are built with Go, so we need to be able to
  # add it in propagatedBuildInputs.
  allowGoReference = true;

  ldflags = [
    "-s"
    "-w"
  ];

  proxyVendor = true;
  sourceRoot = "${finalAttrs.src.name}/v2";
  subPackages = [ "cmd/wails" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Build desktop applications using Go & Web Technologies";
    homepage = "https://wails.io";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ thtrf ];
    platforms = lib.platforms.unix;
    mainProgram = "wails";
  };
})
