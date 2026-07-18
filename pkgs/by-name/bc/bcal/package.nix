{
  lib,
  stdenv,
  fetchFromGitHub,
  bc,
  python3Packages,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bcal";
  version = "2.5";

  src = fetchFromGitHub {
    owner = "jarun";
    repo = "bcal";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-6oJEinw9KmZSinMl0s94oWiNshKsEp9HMUvWl12kLP4=";
  };

  buildInputs = [ readline ];
  doCheck = true;

  nativeCheckInputs = [
    bc
    python3Packages.pytestCheckHook
  ];

  enabledTestPaths = [ "test.py" ];
  installFlags = [ "PREFIX=$(out)" ];

  meta = {
    description = "Storage conversion and expression calculator";
    homepage = "https://github.com/jarun/bcal";
    license = lib.licenses.gpl3Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "bcal";
  };
})
