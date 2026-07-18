{
  lib,
  fetchzip,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "hanazono";
  version = "20170904";

  src = fetchzip {
    url = "mirror://osdn/hanazono-font/68253/hanazono-${version}.zip";
    hash = "sha256-qd0q4wQnHBGLT7C+UQIiOHnxCnRCscMZcj3P5RRxD1U=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype
    install -Dm644 *.txt -t $out/share/doc/hanazono

    runHook postInstall
  '';

  meta = {
    description = "Japanese Mincho-typeface TrueType font";

    longDescription = ''
      Hanazono Mincho typeface is a Japanese TrueType font that developed with a
      support of Grant-in-Aid for Publication of Scientific Research Results
      from Japan Society for the Promotion of Science and the International
      Research Institute for Zen Buddhism (IRIZ), Hanazono University. also with
      volunteers who work together on glyphwiki.org.
    '';

    homepage = "https://fonts.jp/hanazono/";

    # Dual-licensed under OFL and the following:
    # This font is a free software.
    # Unlimited permission is granted to use, copy, and distribute it, with
    # or without modification, either commercially and noncommercially.
    # THIS FONT IS PROVIDED "AS IS" WITHOUT WARRANTY.
    license = [
      lib.licenses.ofl
      lib.licenses.free
    ];

    maintainers = with lib.maintainers; [ mathnerd314 ];
    platforms = lib.platforms.all;
  };
}
