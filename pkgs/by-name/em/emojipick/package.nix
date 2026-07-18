{
  lib,
  fetchFromGitHub,
  dmenu,
  libnotify,
  python3,
  rofi,
  stdenvNoCC,
  xclip,
  emojipick-copy-to-clipboard ? true,
  emojipick-font-family ? "Noto Color Emoji",
  emojipick-font-size ? "18",
  emojipick-print-emoji ? true,
  emojipick-show-notifications ? true,
  emojipick-use-rofi ? false,
}:

let
  boolToInt = b: if b then "1" else "0"; # Convert boolean to integer string
in
stdenvNoCC.mkDerivation {
  pname = "emojipick";
  version = "2021-01-27";

  src = fetchFromGitHub {
    owner = "thingsiplay";
    repo = "emojipick";
    tag = "20210127";
    sha256 = "1kib3cyx6z9v9qw6yrfx5sklanpk5jbxjc317wi7i7ljrg0vdazp";
  };

  # Patch configuration
  # notify-send has to be patched in a bash file
  postPatch = ''
    substituteInPlace emojipick \
      --replace "use_rofi=0" "use_rofi=${boolToInt emojipick-use-rofi}" \
      --replace "copy_to_clipboard=1" "copy_to_clipboard=${boolToInt emojipick-copy-to-clipboard}" \
      --replace "show_notification=1" "show_notification=${boolToInt emojipick-show-notifications}" \
      --replace "print_emoji=1" "print_emoji=${boolToInt emojipick-print-emoji}" \
      --replace "font_family='\"Noto Color Emoji\"'" "font_family='\"${emojipick-font-family}\"'" \
      --replace 'font_size="18"' 'font_size="${emojipick-font-size}"' \
      ${lib.optionalString emojipick-use-rofi "--replace 'rofi ' '${rofi}/bin/rofi '"} \
      --replace notify-send ${libnotify}/bin/notify-send
  '';

  buildInputs = [
    python3
    xclip
    libnotify
  ]
  ++ (if emojipick-use-rofi then [ rofi ] else [ dmenu ]);

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp ./emojipick $out/bin
    cp ./emojiget.py $out/bin

    runHook postInstall
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Get a selection of emojis with dmenu or rofi";
    homepage = "https://github.com/thingsiplay/emojipick";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alexnortung ];
    platforms = lib.platforms.linux;
  };
}
