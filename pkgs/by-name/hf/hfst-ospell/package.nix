{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  icu,
  libarchive,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hfst-ospell";
  version = "0.5.4";

  src = fetchFromGitHub {
    owner = "hfst";
    repo = "hfst-ospell";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BmM0acqPL8qPOJ0KEkcI264xj89v+VaItZ0yS8QLF3o=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    icu
    libarchive
  ];

  # libxmlxx is listed as a dependency but Darwin build fails with it,
  # might also be better in general since libxmlxx in Nixpkgs is 8 years old
  # https://github.com/hfst/hfst-ospell/issues/48#issuecomment-546535653
  configureFlags = [
    "--without-libxmlpp"
    "--without-tinyxml2"
  ];

  meta = {
    description = "HFST spell checker library and command line tool";
    homepage = "https://github.com/hfst/hfst-ospell/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lurkki ];
    platforms = lib.platforms.unix;
  };
})
