{
  lib,
  stdenv,
  fetchurl,
  # Used by the testing package bisq2-webcam-app
  callPackage,
  copyDesktopItems,
  coreutils,
  dpkg,
  gnupg,
  imagemagick,
  # Used by the bundled webcam-app
  libv4l,
  makeBinaryWrapper,
  makeDesktopItem,
  socat,
  tor,
  unzip,
  writeShellScript,
  zip,
  zulu25,
}:

let
  version = "2.1.11";

  jdk = zulu25.override { enableJavaFX = true; };

  bisq-launcher =
    args:
    writeShellScript "bisq-launcher" ''
      rm -fR $HOME/.local/share/Bisq2/tor

      exec "${lib.getExe jdk}" -Djpackage.app-version=@version@ -classpath @out@/lib/app/desktop-app-launcher.jar:@out@/lib/app/* ${args} bisq.desktop_app_launcher.DesktopAppLauncher "$@"
    '';

  # A given release will be signed by either Alejandro Garcia or Henrik Jannsen
  # as indicated in the file
  # https://github.com/bisq-network/bisq2/releases/download/v${version}/signingkey.asc
  publicKey = {
    "387C8307" = fetchurl {
      hash = "sha256-PrRYZLT0xv82dUscOBgQGKNf6zwzWUDhriAffZbNpmI=";
      url = "https://github.com/bisq-network/bisq2/releases/download/v${version}/387C8307.asc";
    };

    "E222AA02" = fetchurl {
      hash = "sha256-31uBpe/+0QQwFyAsoCt1TUWRm0PHfCFOGOx1M16efoE=";
      url = "https://github.com/bisq-network/bisq2/releases/download/v${version}/E222AA02.asc";
    };
  };

  binPath = lib.makeBinPath [
    coreutils
    tor
  ];

  libraryPath = lib.makeLibraryPath [
    stdenv.cc.cc
    libv4l
  ];
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "bisq2";

  # nixpkgs-update: no auto update
  src = fetchurl {
    url = "https://github.com/bisq-network/bisq2/releases/download/v${version}/Bisq-${version}.deb";
    hash = "sha256-Ts0u1Rapgfz/z17U3VSN17/rdACr/KOGmiZjWnGJmcw=";
    downloadToTemp = true;
    # Verify the upstream Debian package prior to extraction.
    # See https://bisq.wiki/Bisq_2#Installation
    # This ensures that a successful build of this Nix package requires the Debian
    # package to pass verification.
    nativeBuildInputs = [ gnupg ];

    postFetch = ''
      pushd $(mktemp -d)
      export GNUPGHOME=./gnupg
      mkdir -m 700 -p $GNUPGHOME
      ln -s $downloadedFile ./Bisq-${version}.deb
      ln -s ${finalAttrs.signature} ./signature.asc
      gpg --import ${publicKey."E222AA02"}
      gpg --import ${publicKey."387C8307"}
      gpg --batch --verify signature.asc Bisq-${version}.deb
      popd
      mv $downloadedFile $out
    '';
  };

  nativeBuildInputs = [
    copyDesktopItems
    dpkg
    imagemagick
    makeBinaryWrapper
    zip
    gnupg
  ];

  buildPhase = ''
    # Replace the Tor binary embedded in tor.jar (which is in the zip archive tor.zip)
    # with the Tor binary from Nixpkgs.

    makeWrapper ${lib.getExe' tor "tor"} ./tor
    zip tor.zip ./tor
    zip opt/bisq2/lib/app/tor.jar tor.zip
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib $out/bin
    cp -r opt/bisq2/lib/app $out/lib

    install -D -m 777 ${bisq-launcher ""} $out/bin/bisq2
    substituteAllInPlace $out/bin/bisq2
    wrapProgram $out/bin/bisq2 --prefix PATH : ${binPath} --prefix LD_LIBRARY_PATH : ${libraryPath}

    install -D -m 777 ${bisq-launcher "-Dglass.gtk.uiScale=2.0"} $out/bin/bisq2-hidpi
    substituteAllInPlace $out/bin/bisq2-hidpi
    wrapProgram $out/bin/bisq2-hidpi --prefix PATH : ${binPath} --prefix LD_LIBRARY_PATH : ${libraryPath}

    for n in 16 24 32 48 64 96 128 256; do
      size=$n"x"$n
      magick convert opt/bisq2/lib/Bisq2.png -resize $size bisq2.png
      install -Dm644 -t $out/share/icons/hicolor/$size/apps bisq2.png
    done;

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Network"
        "P2P"
      ];

      desktopName = "Bisq 2";
      exec = "bisq2";
      genericName = "Decentralized bitcoin exchange";
      icon = "bisq2";
      name = "bisq2";
    })

    (makeDesktopItem {
      categories = [
        "Network"
        "P2P"
      ];

      desktopName = "Bisq 2 (HiDPI)";
      exec = "bisq2-hidpi";
      genericName = "Decentralized bitcoin exchange";
      icon = "bisq2";
      name = "bisq2-hidpi";
    })
  ];

  signature = fetchurl {
    hash = "sha256-/+HDj28uOFQwkrrzKfcQW0T5/qTIeB30Zd10EjeGhlU=";
    url = "https://github.com/bisq-network/bisq2/releases/download/v${version}/Bisq-${version}.deb.asc";
  };

  unpackPhase = ''
    dpkg -x $src .
  '';

  # The bisq2.webcam-app package is for maintainers to test scanning QR codes.
  passthru.webcam-app = callPackage ./webcam-app.nix {
    inherit
      jdk
      libraryPath
      ;

    bisq2 = finalAttrs.finalPackage.out;
  };

  meta = {
    description = "Decentralized bitcoin exchange network";
    homepage = "https://bisq.network";
    license = lib.licenses.mit;

    sourceProvenance = with lib.sourceTypes; [
      binaryBytecode
    ];

    maintainers = with lib.maintainers; [ emmanuelrosa ];

    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    mainProgram = "bisq2";
  };
})
