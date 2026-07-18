{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  autoPatchelfHook,
  bzip2,
  copyDesktopItems,
  kdePackages,
  libgcc,
  libjack2,
  libx11,
  libxfixes,
  libxpm,
  makeDesktopItem,
  makeWrapper,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "stereotool";
  version = "10.71";

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    copyDesktopItems
  ];

  buildInputs = [
    libx11
    alsa-lib
    bzip2
    zlib
    libxpm
    libxfixes
    libjack2
    libgcc
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 alsa $out/bin/stereo_tool_gui
    wrapProgram $out/bin/stereo_tool_gui --prefix PATH : ${lib.makeBinPath [ kdePackages.kdialog ]}
    install -Dm755 jack $out/bin/stereo_tool_gui_jack
    wrapProgram $out/bin/stereo_tool_gui_jack --prefix PATH : ${lib.makeBinPath [ kdePackages.kdialog ]}
    install -Dm755 cmd $out/bin/stereo_tool_cmd
    mkdir -p $out/share/icons/hicolor/48x48/apps
    cp stereo-tool-icon.png $out/share/icons/hicolor/48x48/apps/stereo-tool-icon.png
    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Audio"
        "AudioVideoEditing"
      ];

      comment = "Broadcast Audio Processing";
      desktopName = "Stereotool-Alsa";
      exec = "stereo_tool_gui";
      icon = "stereo-tool-icon";
      name = "stereotool-alsa";
    })
    (makeDesktopItem {
      categories = [
        "AudioVideo"
        "Audio"
        "AudioVideoEditing"
      ];

      comment = "Broadcast Audio Processing";
      desktopName = "Stereotool-Jack";
      exec = "stereo_tool_gui_jack";
      icon = "stereo-tool-icon";
      name = "stereotool-jack";
    })
  ];

  srcs =
    let
      versionNoPoint = lib.replaceStrings [ "." ] [ "" ] version;
    in
    [
      (fetchurl {
        hash = "sha256-dcivH6Cc7pdQ99m80vS4E5mp/SHtTlNu1EHc+0ALIGM=";
        name = "stereo-tool-icon.png";
        url = "https://download.thimeo.com/stereo_tool_icon_${versionNoPoint}.png";
      })
    ]
    ++ (
      {
        # Sources if the system is aarch32-linux
        aarch32-linux = [
          (fetchurl {
            hash = "sha256-ryw4m08Ru2GI/Wq0UZwjmect7OAHaftfy+0J1S1bYh8=";
            name = "alsa";
            url = "https://download.thimeo.com/stereo_tool_gui_pi2_${versionNoPoint}";
          })
          (fetchurl {
            hash = "sha256-ryw4m08Ru2GI/Wq0UZwjmect7OAHaftfy+0J1S1bYh8=";
            name = "jack";
            url = "https://download.thimeo.com/stereo_tool_gui_jack_pi2_${versionNoPoint}";
          })
          (fetchurl {
            hash = "sha256-l9VWraDHJXfNJVb8/VvHENvdknT6ccPBmt/mGlwND00=";
            name = "cmd";
            url = "https://download.thimeo.com/stereo_tool_pi2_${versionNoPoint}";
          })
        ];

        # Sources if the system is aarch64-linux
        aarch64-linux = [
          (fetchurl {
            hash = "sha256-nr3VlRpWELe4vlaKenPa3ZtOHjD66BXbGDd2WjTI70E=";
            name = "alsa";
            url = "https://download.thimeo.com/stereo_tool_gui_pi2_64_${versionNoPoint}";
          })
          (fetchurl {
            hash = "sha256-nr3VlRpWELe4vlaKenPa3ZtOHjD66BXbGDd2WjTI70E=";
            name = "jack";
            url = "https://download.thimeo.com/stereo_tool_gui_jack_pi2_64_${versionNoPoint}";
          })
          (fetchurl {
            hash = "sha256-QyJ/BulqWEIpGfbd6qGT4ejOtdVJ0/M2pEvJasRZUNE=";
            name = "cmd";
            url = "https://download.thimeo.com/stereo_tool_pi2_64_${versionNoPoint}";
          })
        ];

        # Sources if the system is 32bits i686
        i686-linux = [
          (fetchurl {
            hash = "sha256-OnGn/OUkXFZ4SnmibpF/0kxeq8YZIWMMVafy6i96GeA=";
            # The name is the name of this source in the build directory
            name = "alsa";
            url = "https://download.thimeo.com/stereo_tool_gui_${versionNoPoint}";
          })
          (fetchurl {
            hash = "sha256-OnGn/OUkXFZ4SnmibpF/0kxeq8YZIWMMVafy6i96GeA=";
            name = "jack";
            url = "https://download.thimeo.com/stereo_tool_gui_jack_${versionNoPoint}";
          })
          (fetchurl {
            hash = "sha256-GDpfSeL14XkvroIF6pm5CzNYiEz/v5uzfyjw+7K1idE=";
            name = "cmd";
            url = "https://download.thimeo.com/stereo_tool_cmd_${versionNoPoint}";
          })
        ];

        # Alsa version for 64bits.
        x86_64-linux = [
          (fetchurl {
            hash = "sha256-YDrB7MX2EbG9Eknx5XlOAaW/2sPTZzPIGXzFcwKGqK8=";
            name = "alsa";
            url = "https://download.thimeo.com/stereo_tool_gui_64_${versionNoPoint}";
          })
          # Jack version for 64bits.
          (fetchurl {
            hash = "sha256-YDrB7MX2EbG9Eknx5XlOAaW/2sPTZzPIGXzFcwKGqK8=";
            name = "jack";
            url = "https://download.thimeo.com/stereo_tool_gui_jack_64_${versionNoPoint}";
          })
          # Cmd version for 64bits
          (fetchurl {
            hash = "sha256-+hm8G5jwgFqDzy7BsYSfJh3x9asx7voc4NdIqkBDGmE=";
            name = "cmd";
            url = "https://download.thimeo.com/stereo_tool_cmd_64_${versionNoPoint}";
          })
        ];
      }
      .${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}")
    );

  unpackPhase = ''
    for srcFile in $srcs; do
      cp $srcFile $(stripHash $srcFile)
    done
  '';

  meta = {
    description = "Stereo Tool is a software-based audio processor which offers outstanding audio quality and comes with many unique features";
    homepage = "https://www.thimeo.com/stereo-tool/";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ RudiOnTheAir ];

    platforms = [
      "aarch64-linux"
      "aarch32-linux"
      "x86_64-linux"
      "i686-linux"
    ];

    mainProgram = "stereo_tool_gui";
  };

}
