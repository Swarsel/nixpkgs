{
  lib,
  fetchFromGitHub,
  alsa-utils,
  coreutils,
  dbus,
  dnsutils,
  gdk-pixbuf,
  iproute2,
  libnotify,
  libx11,
  makeWrapper,
  nix-update-script,
  pkg-config,
  rustPlatform,
  wirelesstools,
  enableAlsaUtils ? true,
  enableNetwork ? true,
}:

let
  bins =
    lib.optionals enableAlsaUtils [
      alsa-utils
      coreutils
    ]
    ++ lib.optionals enableNetwork [
      dnsutils
      iproute2
      wirelesstools
    ];
in

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "dwm-status";
  version = "1.11.0";

  src = fetchFromGitHub {
    owner = "Gerschtli";
    repo = "dwm-status";
    tag = finalAttrs.version;
    hash = "sha256-2E/I8xRo29jaPYupAd9udgjv/OdDNdtWkVp/SPRQkxY=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    dbus
    gdk-pixbuf
    libnotify
    libx11
  ];

  cargoHash = "sha256-o6gzP0mo7+np5Ba22gPAHcPPXoFTYThNsMr6nNC/Zm4=";

  postInstall = lib.optionalString (bins != [ ]) ''
    wrapProgram $out/bin/dwm-status --prefix "PATH" : "${lib.makeBinPath bins}"
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Highly performant and configurable DWM status service";
    homepage = "https://github.com/Gerschtli/dwm-status";
    changelog = "https://github.com/Gerschtli/dwm-status/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      gepbird
      gerschtli
    ];

    platforms = lib.platforms.linux;
    mainProgram = "dwm-status";
  };
})
