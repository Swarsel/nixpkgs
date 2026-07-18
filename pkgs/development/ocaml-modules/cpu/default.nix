{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  buildDunePackage,
}:

buildDunePackage (finalAttrs: {
  pname = "cpu";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "UnixJunkie";
    repo = "cpu";
    tag = "v${finalAttrs.version}";
    hash = "sha256-O0pvNRONlprQ4XVG3858cnDo0WDJWOaEfH3DFeAzOe4=";
  };

  nativeBuildInputs = [ autoconf ];

  preConfigure = ''
    autoconf
    autoheader
  '';

  hardeningDisable = lib.optional stdenv.hostPlatform.isDarwin "strictoverflow";

  meta = {
    description = "Core pinning library";
    homepage = "https://github.com/UnixJunkie/cpu";
    license = lib.licenses.lgpl2;
    maintainers = [ lib.maintainers.bcdarwin ];
  };
})
