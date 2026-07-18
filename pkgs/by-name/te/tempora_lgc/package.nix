{
  lib,
  stdenv,
  fetchurl,
}:
let
  srcs = [
    (fetchurl {
      sha256 = "1yfbi62j6gjmzglxz29m6x6lxqpxghcqjjh916qn8in74ba5v0gq";
      url = "http://www.ttfotf.com/download-font/tempora-lgc-unicode-bold-italic.otf";
    })
    (fetchurl {
      sha256 = "0bfbl1h9h1022km2rg1zwl9lpabhnwdsvzdp0bwmf0wbm62550cp";
      url = "http://www.ttfotf.com/download-font/tempora-lgc-unicode-bold.otf";
    })
    (fetchurl {
      sha256 = "10m9j4bvr6c4zp691wxm4hvzhph2zlfsxk1nmbsb9vn1i6vfgz04";
      url = "http://www.ttfotf.com/download-font/tempora-lgc-unicode-italic.otf";
    })
    (fetchurl {
      sha256 = "0iwa8wyydcpjss6d1jy4jibqxpvzph4vmaxwwmndpsqy1fz64y9i";
      url = "http://www.ttfotf.com/download-font/tempora-lgc-unicode.otf";
    })
  ];
  nativeBuildInputs = [
  ];
in
stdenv.mkDerivation {
  inherit nativeBuildInputs;
  inherit srcs;

  installPhase = ''
    mkdir -p "$out/share/fonts/opentype/public"
    cp ${toString srcs} "$out/share/fonts/opentype/public"
  '';

  name = "tempora-lgc";
  outputHash = "1kwj31cjgdirqvh6bxs4fnvvr1ppaz6z8w40kvhkivgs69jglmzw";
  outputHashAlgo = "sha256";
  outputHashMode = "recursive";

  meta = {
    description = "Tempora font";
    license = lib.licenses.gpl2;
    maintainers = [ lib.maintainers.raskin ];
  };
}
