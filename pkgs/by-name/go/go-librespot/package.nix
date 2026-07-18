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
  pname = "go-librespot";
  version = "0.7.4";

  src = fetchFromGitHub {
    owner = "devgianlu";
    repo = "go-librespot";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TJQMfZRuWDu83QZeCU+EQ90WX6gT5+nXbYRIqfvXRp8=";
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

  vendorHash = "sha256-kCzzybOEP4Tp7OGFZBjIP1FgcQ9u+lgO3931gbaG9hA=";

  postInstall = ''
    mv $out/bin/daemon $out/bin/go-librespot
  '';

  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-X github.com/devgianlu/go-librespot.version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/daemon" ];

  meta = {
    description = "Yet another open source Spotify client, written in Go";
    homepage = "https://github.com/devgianlu/go-librespot";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      sweenu
      emilylange
    ];

    mainProgram = "go-librespot";
  };
})
