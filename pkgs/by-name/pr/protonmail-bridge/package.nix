{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libfido2,
  libsecret,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "protonmail-bridge";
  version = "3.25.0";

  src = fetchFromGitHub {
    owner = "ProtonMail";
    repo = "proton-bridge";
    rev = "v${finalAttrs.version}";
    hash = "sha256-kKwsfFns5eKOEyljUB5DRozb0N6sabY4RGYt9MeePOo=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libsecret
    libfido2
  ];

  vendorHash = "sha256-Ox/Y6aVkL14YkN2kasT7DtBZkcUA1qcrsb0Yoa4Oizw=";

  preBuild = ''
    patchShebangs ./utils/
    (cd ./utils/ && ./credits.sh bridge)
  '';

  postInstall = ''
    mv $out/bin/Desktop-Bridge $out/bin/protonmail-bridge # The cli is named like that in other distro packages
  '';

  ldflags =
    let
      constants = "github.com/ProtonMail/proton-bridge/v3/internal/constants";
    in
    [
      "-X ${constants}.Version=${finalAttrs.version}"
      "-X ${constants}.Revision=${finalAttrs.src.rev}"
      "-X ${constants}.buildTime=unknown"
      "-X ${constants}.FullAppName=ProtonMailBridge" # Should be "Proton Mail Bridge", but quoting doesn't seems to work in nix's ldflags
    ];

  subPackages = [
    "cmd/Desktop-Bridge"
  ];

  meta = {
    description = "Use your ProtonMail account with your local e-mail client";

    longDescription = ''
      An application that runs on your computer in the background and seamlessly encrypts
      and decrypts your mail as it enters and leaves your computer.

      To work, use secret-service freedesktop.org API (e.g. Gnome keyring) or pass.
    '';

    homepage = "https://github.com/ProtonMail/proton-bridge";
    changelog = "https://github.com/ProtonMail/proton-bridge/blob/${finalAttrs.src.rev}/Changelog.md";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      mrfreezeex
      daniel-fahey
    ];

    mainProgram = "protonmail-bridge";
    downloadPage = "https://github.com/ProtonMail/proton-bridge/releases";
  };
})
