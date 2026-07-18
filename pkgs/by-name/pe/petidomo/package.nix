{
  lib,
  stdenv,
  fetchurl,
  bison,
  flex,
  versionCheckHook,
  sendmailPath ? "/run/wrappers/bin/sendmail",
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "petidomo";
  version = "4.3";

  src = fetchurl {
    url = "mirror://sourceforge/petidomo/petidomo-${finalAttrs.version}.tar.gz";
    hash = "sha256-ddNw0fq2MQLJd6YCmIkf9lvq9/Xscl94Ds8xR1hfjXQ=";
  };

  patches = [
    # https://github.com/peti/petidomo/pull/1
    ./fix-gcc15.patch
  ];

  buildInputs = [
    flex
    bison
  ];

  configureFlags = [ "--with-mta=${sendmailPath}" ];
  # test.c:43:11: error: implicit declaration of function 'gets'; did you mean 'fgets'?
  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";
  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;

  meta = {
    description = "Simple and easy to administer mailing list server";
    homepage = "https://petidomo.sourceforge.net/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.peti ];
    platforms = lib.platforms.unix;
    mainProgram = "petidomo";
  };
})
