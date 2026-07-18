{
  lib,
  stdenv,
  fetchFromGitHub,
  glib,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liblqr-1";
  version = "0.4.3";

  src = fetchFromGitHub {
    owner = "carlobaldassi";
    repo = "liblqr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-RN58r9AUceziWfZBqyAjjPXrdfilR6cxn3FzQxiQEdE=";
  };

  outputs = [
    "out"
    "dev"
  ];

  nativeBuildInputs = [ pkg-config ];
  propagatedBuildInputs = [ glib ];

  # Fix build with gcc15
  env = lib.optionalAttrs stdenv.cc.isGNU {
    NIX_CFLAGS_COMPILE = "-std=gnu17";
  };

  meta = {
    description = "Seam-carving C/C++ library called Liquid Rescaling";
    homepage = "http://liblqr.wikidot.com";

    license = with lib.licenses; [
      gpl3
      lgpl3
    ];

    platforms = lib.platforms.all;
  };
})
