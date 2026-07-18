{
  lib,
  aileron,
  eunomia,
  f1_8,
  f5_6,
  fa_1,
  ferrum,
  medio,
  melete,
  nacelle,
  penna,
  route159,
  seshat,
  symlinkJoin,
  tenderness,
  vegur,
}:

symlinkJoin {
  name = "dotcolon-fonts";

  paths = [
    aileron
    vegur
    f5_6
    tenderness
    medio
    ferrum
    seshat
    penna
    eunomia
    route159
    f1_8
    nacelle
    melete
    fa_1
  ];

  meta = {
    description = "Font Collection by Sora Sagano";
    homepage = "https://dotcolon.net/";

    license = with lib.licenses; [
      cc0
      ofl
    ];

    maintainers = with lib.maintainers; [ minijackson ];
    platforms = lib.platforms.all;
  };
}
