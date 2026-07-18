{
  lib,
  fetchurl,
  stdenvNoCC,
  symlinkJoin,
}:

let
  version = "17.0.0";

  fetchData =
    { hash, suffix }:
    stdenvNoCC.mkDerivation {
      inherit version;
      pname = "unicode-emoji-${suffix}";

      src = fetchurl {
        inherit hash;
        url = "https://www.unicode.org/Public/${version}/emoji/emoji-${suffix}.txt";
      };

      installPhase = ''
        runHook preInstall

        installDir="$out/share/unicode/emoji"
        mkdir -p "$installDir"
        cp "$src" "$installDir/emoji-${suffix}.txt"

        runHook postInstall
      '';

      dontUnpack = true;
    };

  srcs = {
    emoji-sequences = fetchData {
      hash = "sha256-EsyCZ9wzy9Ee0yvPb8XcKtnHp3uuG9+6L0GxubPq2N0=";
      suffix = "sequences";
    };

    emoji-test = fetchData {
      hash = "sha256-HYqUT4jXlS9+98UWf+88Z5lbyuJFQ5SXECMbA6IBrNo=";
      suffix = "test";
    };

    emoji-zwj-sequences = fetchData {
      hash = "sha256-WyVEHa7SMisGjF5wzaUilGpPAnTfhkRFoZZakuX8XK0=";
      suffix = "zwj-sequences";
    };
  };
in

symlinkJoin {
  inherit version;
  pname = "unicode-emoji";
  paths = lib.attrValues srcs;
  passthru = srcs;

  meta = {
    description = "Unicode Emoji Data Files";
    homepage = "https://home.unicode.org/emoji/";
    license = lib.licenses.unicode-dfs-2016;
    platforms = lib.platforms.all;
  };
}
