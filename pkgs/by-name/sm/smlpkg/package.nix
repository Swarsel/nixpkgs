{
  lib,
  stdenv,
  fetchFromGitHub,
  mlton,
  unzip,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "smlpkg";
  version = "0.1.7";

  src = fetchFromGitHub {
    owner = "diku-dk";
    repo = "smlpkg";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-zdWObV/W6fmQ6bFznEVEtp95D8t2YZd45sIC15XQwYM=";
  };

  nativeBuildInputs = [ mlton ];
  buildFlags = [ "all" ];
  # Set as an environment variable in all the phase scripts.
  env.MLCOMP = "mlton";
  doCheck = true;
  nativeCheckInputs = [ unzip ];

  # We cannot run the pkgtests, as Nix does not allow network
  # connections.
  checkPhase = ''
    runHook preCheck
    make -C src test
    runHook postCheck
  '';

  enableParallelBuilding = true;
  installFlags = [ "prefix=$(out)" ];

  meta = {
    description = "Generic package manager for Standard ML libraries and programs";
    homepage = "https://github.com/diku-dk/smlpkg";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ athas ];
    platforms = mlton.meta.platforms;
    mainProgram = "smlpkg";
  };
})
