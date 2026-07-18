{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  buildGoModule,
  cairo,
  gdk-pixbuf,
  glib,
  gtk3,
  pkg-config,
  wrapGAppsHook3,
}:

buildGoModule {
  pname = "coyim";
  version = "0.4.1-unstable-2023-09-21";

  src = fetchFromGitHub {
    owner = "coyim";
    repo = "coyim";
    rev = "3f84daa8c27277543b1b4ad4536dde5100d9df12";
    hash = "sha256-lzhcUSBuAgYwcmdwnqNxKG0P6ZSjWeLS/g/gaF171D4=";
  };

  postPatch = ''
    # fixes build on aarch64
    rm -v windows_amd64_icon.syso
  '';

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    cairo
    gdk-pixbuf
    gtk3
    adwaita-icon-theme
  ];

  vendorHash = "sha256-zG7r/Db6XiwKoHRduGj3tEh/KT1hsuBoSGLYaZ+qO0Y=";

  meta = {
    description = "Safe and secure chat client";
    homepage = "https://coy.im/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ PapayaJackal ];
    mainProgram = "coyim";
    broken = stdenv.hostPlatform.isDarwin;
  };
}
