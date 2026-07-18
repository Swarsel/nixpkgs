{
  lib,
  fetchFromGitHub,
  alsa-lib,
  dbus,
  fontconfig,
  libpulseaudio,
  libxkbcommon,
  pkg-config,
  rustPlatform,
  wayland,
  enableAlsaWidget ? true,
  enablePulseaudioWidget ? true,
}:

let
  pname = "wldash";
  version = "0.3.0";
  libraryPath = lib.makeLibraryPath [
    wayland
    libxkbcommon
  ];
in
rustPlatform.buildRustPackage {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "kennylevinsen";
    repo = "wldash";
    rev = "v${version}";
    hash = "sha256-ZzsBD3KKTT+JGiFCpdumPyVAE2gEJvzCq+nRnK3RdxI=";
  };

  strictDeps = true;
  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    dbus
    fontconfig
  ]
  ++ lib.optionals enableAlsaWidget [ alsa-lib ]
  ++ lib.optionals enablePulseaudioWidget [ libpulseaudio ];

  cargoHash = "sha256-gvIsm6D6ZvRm0APw+xpayY+yt2IedMpWoa/hmvIpmV8=";

  postInstall = ''
    patchelf --set-rpath ${libraryPath}:$(patchelf --print-rpath $out/bin/wldash) $out/bin/wldash
  '';

  buildFeatures = [
    "yaml-cfg"
    "json-cfg"
  ]
  ++ lib.optionals enableAlsaWidget [ "alsa-widget" ]
  ++ lib.optionals enablePulseaudioWidget [ "pulseaudio-widget" ];

  buildNoDefaultFeatures = true;

  cargoPatches = [
    ./0001-Update-Cargo.lock.patch
    ./0002-Update-fontconfig.patch
  ];

  dontPatchELF = true;

  meta = {
    description = "Wayland launcher/dashboard";
    homepage = "https://github.com/kennylevinsen/wldash";
    license = lib.licenses.gpl3;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ bbenno ];
    platforms = lib.platforms.linux;
    mainProgram = "wldash";
  };
}
