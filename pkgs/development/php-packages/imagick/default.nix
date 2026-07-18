{
  lib,
  buildPecl,
  imagemagick,
  pcre2,
  pkg-config,
}:

buildPecl {
  pname = "imagick";
  version = "3.8.1";
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pcre2 ];
  configureFlags = [ "--with-imagick=${imagemagick.dev}" ];
  depsBuildBuild = [ pkg-config ];
  hash = "sha256-OjWHwKUkwX0NrZZzoWC5DNd26DaDhHThc7VJ7YZDUu4=";

  meta = {
    description = "Imagick is a native php extension to create and modify images using the ImageMagick API";
    homepage = "https://pecl.php.net/package/imagick";
    license = lib.licenses.php301;
    teams = [ lib.teams.php ];
  };
}
