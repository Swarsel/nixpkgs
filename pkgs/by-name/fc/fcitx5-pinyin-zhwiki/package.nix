{
  lib,
  fetchurl,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "fcitx5-pinyin-zhwiki";
  version = "0.3.0";

  installPhase = ''
    runHook preInstall

    for dict in $srcs; do
      install -D $dict $out/share/fcitx5/pinyin/dictionaries/$(basename $(stripHash $dict) | sed 's/-[0-9]\{8\}//')
    done

    runHook postInstall
  '';

  date = "20251223";
  dontUnpack = true;

  srcs = [
    (fetchurl {
      hash = "sha256-J3sDjcty3IWrnQWIn4dEPL56/Qipl/hJMu02baP2094=";
      url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/${finalAttrs.version}/web-slang-${finalAttrs.date}.dict";
    })
    (fetchurl {
      hash = "sha256-1/KKfeRhor1LGYBrOHqLvxfK9Byv3AplzqVX3lRO50Y=";
      url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/${finalAttrs.version}/zhwiki-${finalAttrs.date}.dict";
    })
    (fetchurl {
      hash = "sha256-UXJ2uMAI6DK/hCHNuZEydPYMt0u/PfIv6RnCC+G2UPI=";
      url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/${finalAttrs.version}/zhwikisource-${finalAttrs.date}.dict";
    })
    (fetchurl {
      hash = "sha256-bG4LPuJDdNgB1N6SNQy0cINRBWaQEMdNONSaptjkFHk=";
      url = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki/releases/download/${finalAttrs.version}/zhwiktionary-${finalAttrs.date}.dict";
    })
  ];

  meta = {
    description = "Fcitx 5 pinyin dictionary from zh.wikipedia.org";
    homepage = "https://github.com/felixonmars/fcitx5-pinyin-zhwiki";

    license = with lib.licenses; [
      unlicense
      cc-by-sa-40
    ];

    maintainers = with lib.maintainers; [ Guanran928 ];
    platforms = lib.platforms.all;
  };
})
