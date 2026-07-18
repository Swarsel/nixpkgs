{
  lib,
  stdenv,
  fetchurl,
  bdftopcf,
  fonttosfnt,
  libfaketime,
  mkfontscale,
}:

stdenv.mkDerivation {
  pname = "ucs-fonts";
  version = "20090406";

  outputs = [
    "out"
    "bdf"
  ];

  nativeBuildInputs = [
    bdftopcf
    libfaketime
    fonttosfnt
    mkfontscale
  ];

  buildPhase = ''
    for i in *.bdf; do
      name=$(basename "$i" .bdf)

      # generate pcf fonts (for X11 applications)
      bdftopcf -t "$i" | gzip -n -9 -c > "$name.pcf.gz"

      # generate otb fonts (for GTK applications)
      faketime -f "1970-01-01 00:00:01" \
      fonttosfnt -v -o "$name.otb" "$i"
    done
  '';

  installPhase = ''
    install -m 644 -D *.otb *.pcf.gz -t "$out/share/fonts/misc"
    install -m 644 -D *.bdf -t "$bdf/share/fonts/misc"

    mkfontdir "$out/share/fonts/misc"
    mkfontdir "$bdf/share/fonts/misc"
  '';

  sourceRoot = ".";

  srcs = [
    (fetchurl {
      sha256 = "12hgizg25fzmk10wjl0c88x97h3pg5r9ga122s3y28wixz6x2bvh";
      url = "http://www.cl.cam.ac.uk/~mgk25/download/ucs-fonts.tar.gz";
    })
    (fetchurl {
      sha256 = "0ibjy4xpz5j373hsdr8bx99czfpclqmviwwv768j8n7z12z3wa51";
      url = "http://www.cl.cam.ac.uk/~mgk25/download/ucs-fonts-asian.tar.gz";
    })
    (fetchurl {
      sha256 = "08vqr8yb636xa1s28vf3pm22dzkia0gisvsi2svqjqh4kk290pzh";
      url = "http://www.cl.cam.ac.uk/~mgk25/download/ucs-fonts-75dpi100dpi.tar.gz";
    })
  ];

  meta = {
    description = "Unicode bitmap fonts";
    homepage = "https://www.cl.cam.ac.uk/~mgk25/ucs-fonts.html";
    license = lib.licenses.publicDomain;
    maintainers = [ lib.maintainers.raskin ];
    platforms = lib.platforms.all;
  };
}
