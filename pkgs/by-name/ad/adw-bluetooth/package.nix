{
  lib,
  stdenv,
  fetchFromGitHub,
  blueprint-compiler,
  buildGoModule,
  desktop-file-utils,
  gjs,
  libadwaita,
  meson,
  ninja,
  pkg-config,
  typescript,
  wrapGAppsHook4,
}:

let
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "ezratweaver";
    repo = "adw-bluetooth";
    tag = version;
    hash = "sha256-0rySzx03KeKeqtl0yrbnj/tVbpVPBAKDz+1qLQ5kZRc=";
  };

  daemon = buildGoModule {
    inherit version;
    pname = "adw-bluetooth-daemon";
    src = src + "/daemon";
    vendorHash = "sha256-7tiSwNhq6e4LEh4lUkfh2i4tEdWWL6TxQpYYwYKsfog=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit version src;
  pname = "adw-bluetooth";

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    blueprint-compiler
    typescript
    desktop-file-utils
    wrapGAppsHook4
  ];

  buildInputs = [
    gjs
    libadwaita
  ];

  mesonFlags = [ "-Dbuild_daemon=false" ];

  postInstall = ''
    mkdir -p $out/libexec
    ln -s ${daemon}/bin/daemon $out/libexec/adw-bluetooth-daemon
  '';

  meta = {
    description = "GNOME Inspired LibAdwaita Bluetooth Applet";
    homepage = "https://github.com/ezratweaver/adw-bluetooth";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ezratweaver ];
    platforms = lib.platforms.linux;
  };
})
