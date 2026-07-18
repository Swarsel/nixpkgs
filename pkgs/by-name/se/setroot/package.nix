{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  imlib2,
  libx11,
  libxinerama,
  pkg-config,
  enableXinerama ? true,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "setroot";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "ttzhou";
    repo = "setroot";
    rev = "v${finalAttrs.version}";
    sha256 = "0w95828v0splk7bj5kfacp4pq6wxpyamvyjmahyvn5hc3ycq21mq";
  };

  patches = [
    (fetchpatch {
      sha256 = "sha256-e0iMSpiOmTOpQnp599fjH2UCPU4Oq1VKXcVypVoR9hw=";
      url = "https://github.com/ttzhou/setroot/commit/d8ff8edd7d7594d276d741186bf9ccf0bce30277.patch";
    })
  ];

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libx11
    imlib2
  ]
  ++ lib.optionals enableXinerama [ libxinerama ];

  buildFlags = [ (if enableXinerama then "xinerama=1" else "xinerama=0") ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Simple X background setter inspired by imlibsetroot and feh";
    homepage = "https://github.com/ttzhou/setroot";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "setroot";
  };
})
