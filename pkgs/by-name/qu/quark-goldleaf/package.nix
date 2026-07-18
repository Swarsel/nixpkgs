{
  lib,
  fetchFromGitHub,
  copyDesktopItems,
  gtk3,
  imagemagick,
  jdk,
  makeDesktopItem,
  maven,
  udevCheckHook,
  wrapGAppsHook3,
}:

let
  jdk' = jdk.override { enableJavaFX = true; };
in
maven.buildMavenPackage rec {
  pname = "quark-goldleaf";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "XorTroll";
    repo = "Goldleaf";
    tag = version;
    hash = "sha256-ldGNtNmn7ln53JvxRkP1AMPslKH0JtSPhBkyqytSx20=";
  };

  patches = [
    ./fix-maven-plugin-versions.patch
    ./remove-pom-jfx.patch
  ];

  nativeBuildInputs = [
    imagemagick # for icon conversion
    copyDesktopItems
    wrapGAppsHook3
    udevCheckHook
  ];

  buildInputs = [ gtk3 ];

  installPhase = ''
    runHook preInstall

    install -Dm644 ${./99-quark-goldleaf.rules} $out/etc/udev/rules.d/99-quark-goldleaf.rules
    install -Dm644 target/Quark.jar $out/share/java/quark-goldleaf.jar

    for size in 16 24 32 48 64 128; do
      mkdir -p $out/share/icons/hicolor/"$size"x"$size"/apps
      convert -resize "$size"x"$size" src/main/resources/Icon.png $out/share/icons/hicolor/"$size"x"$size"/apps/quark-goldleaf.png
    done

    runHook postInstall
  '';

  doInstallCheck = true;

  postFixup = ''
    # This is in postFixup because gappsWrapperArgs are generated during preFixup
    makeWrapper ${jdk'}/bin/java $out/bin/quark-goldleaf \
        "''${gappsWrapperArgs[@]}" \
        --add-flags "-jar $out/share/java/quark-goldleaf.jar"
  '';

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Utility"
        "FileTransfer"
      ];

      comment = meta.description;
      desktopName = "Quark";
      exec = "quark-goldleaf";
      icon = "quark-goldleaf";

      keywords = [
        "nintendo"
        "switch"
        "goldleaf"
      ];

      name = "quark-goldleaf";
      terminal = false;
    })
  ];

  # don't double-wrap
  dontWrapGApps = true;
  mvnHash = "sha256-gA3HsQZFa2POP9cyJLb1l8t3hrJYzDowhJU+5Xl79p4=";
  mvnJdk = jdk';
  # set fixed build timestamp for deterministic jar
  mvnParameters = "-Dproject.build.outputTimestamp=1980-01-01T00:00:02Z";
  sourceRoot = "${src.name}/Quark";

  meta = {
    description = "GUI tool for transfering files between a computer and a Nintendo Switch running Goldleaf";

    longDescription = ''
      ${meta.description}

      For the program to work properly, you will have to install Nintendo Switch udev rules.

      You can either do this by enabling the NixOS module:

      `programs.quark-goldleaf.enable = true;`

      or by adding the package manually to udev packages:

      `services.udev.packages = [ pkgs.quark-goldleaf ];`
    '';

    homepage = "https://github.com/XorTroll/Goldleaf#quark-and-remote-browsing";
    changelog = "https://github.com/XorTroll/Goldleaf/releases/tag/${src.rev}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ tomasajt ];
    platforms = with lib.platforms; linux ++ darwin;
    mainProgram = "quark-goldleaf";
  };
}
