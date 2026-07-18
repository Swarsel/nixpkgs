{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  libnotify,
  makeDesktopItem,
  makeWrapper,
  olm,
  pulseaudio,
  sound-theme-freedesktop,
}:

buildGoModule rec {
  pname = "gomuks";
  version = "0.3.1";

  src = fetchFromGitHub {
    owner = "gomuks";
    repo = "gomuks";
    rev = "v${version}";
    sha256 = "sha256-bDJXo8d9K5UO599HDaABpfwc9/dJJy+9d24KMVZHyvI=";
  };

  nativeBuildInputs = [ makeWrapper ];
  buildInputs = [ olm ];
  vendorHash = "sha256-0my58bVKLWbdTwhAnXMruNjujd07NXFn4bkRe1cUYpE=";
  doCheck = false;

  postInstall = ''
    cp -r ${
      makeDesktopItem {
        categories = [
          "Network"
          "Chat"
        ];

        comment = meta.description;
        desktopName = "Gomuks";
        exec = "@out@/bin/gomuks";
        genericName = "Matrix client";
        name = "net.maunium.gomuks.desktop";
        terminal = true;
      }
    }/* $out/
    substituteAllInPlace $out/share/applications/*
    wrapProgram $out/bin/gomuks \
      --prefix PATH : "${
        lib.makeBinPath (
          lib.optionals stdenv.hostPlatform.isLinux [
            libnotify
            pulseaudio
          ]
        )
      }" \
      --set-default GOMUKS_SOUND_NORMAL "${sound-theme-freedesktop}/share/sounds/freedesktop/stereo/message-new-instant.oga" \
      --set-default GOMUKS_SOUND_CRITICAL "${sound-theme-freedesktop}/share/sounds/freedesktop/stereo/complete.oga"
  '';

  meta = {
    description = "Terminal based Matrix client written in Go";
    homepage = "https://maunium.net/go/gomuks/";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ chvp ];
    mainProgram = "gomuks";
  };
}
