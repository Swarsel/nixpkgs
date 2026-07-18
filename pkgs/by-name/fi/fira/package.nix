{
  lib,
  fira-mono,
  fira-sans,
  symlinkJoin,
}:

symlinkJoin {
  inherit (fira-sans) version;
  pname = "fira";

  paths = [
    fira-mono
    fira-sans
  ];

  meta = {
    description = "Font family including Fira Sans and Fira Mono";
    homepage = "https://carrois.com/fira/";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
}
