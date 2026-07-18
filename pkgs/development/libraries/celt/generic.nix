{
  lib,
  stdenv,
  src,
  version,
  libogg ? null, # if disabled only the library will be built
  liboggSupport ? true,
  prePatch ? "",
  ...
}:

# The celt codec has been deprecated and is now a part of the opus codec

stdenv.mkDerivation {
  inherit version;
  inherit src;
  inherit prePatch;
  pname = "celt";

  outputs = [
    "out"
    "dev"
  ];

  buildInputs = [ ] ++ lib.optional liboggSupport libogg;
  doCheck = false; # fails

  meta = {
    description = "Ultra-low delay audio codec";
    homepage = "https://gitlab.xiph.org/xiph/celt"; # http://www.celt-codec.org/ is gone
    license = lib.licenses.bsd2;

    maintainers = with lib.maintainers; [
      raskin
    ];

    platforms = lib.platforms.unix;
  };
}
