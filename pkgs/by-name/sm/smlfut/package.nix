{
  lib,
  stdenv,
  fetchFromGitHub,
  futhark,
  mlkit,
  mlton,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smlfut";
  version = "1.6.4";

  src = fetchFromGitHub {
    owner = "diku-dk";
    repo = "smlfut";
    rev = "v${finalAttrs.version}";
    hash = "sha256-xICcobdvSdHZfNxz4WRDOsaL4JGFRK7LmhMzKOZY5FY=";
  };

  nativeBuildInputs = [ mlton ];
  env.MLCOMP = "mlton";
  doCheck = true;

  nativeCheckInputs = [
    futhark
    mlkit
  ];

  checkTarget = "run_test";
  enableParallelBuilding = true;
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Allow SML programs to call Futhark programs";
    homepage = "https://github.com/diku-dk/smlfut";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ athas ];
    platforms = mlton.meta.platforms;
    mainProgram = "smlfut";
  };
})
