{
  lib,
  stdenv,
  fetchFromGitHub,
  alsa-lib,
  buildGoModule,
  flac,
  libogg,
  libvorbis,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "lazyspotify-librespot";
  version = "0.7.1.1";

  src = fetchFromGitHub {
    owner = "dubeyKartikay";
    repo = "go-librespot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Hq9Qk8f8oKzpBwsbLNAvPO7qam3bh4L4RPUQC67/NZY=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    flac
    libogg
    libvorbis
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    alsa-lib
  ];

  vendorHash = "sha256-5J5i2Wc0zHCdvJ3aUkftXeMKS5X8jWimup0Ir4HLuS8=";

  # rename the generic daemon binary for identification
  postInstall = ''
    install -Dm755 $out/bin/daemon $out/bin/lazyspotify-librespot
    rm $out/bin/daemon
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/devgianlu/go-librespot.version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/daemon" ];

  meta = {
    description = "Librespot daemon tailored for lazyspotify";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ eConnah ];
    mainProgram = "lazyspotify-librespot";
  };
})
