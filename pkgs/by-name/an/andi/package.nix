{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  glib,
  gsl,
  libdivsufsort,
  llvmPackages,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "andi";
  version = "1.15";

  src = fetchFromGitHub {
    owner = "evolbioinf";
    repo = "andi";
    tag = "v${finalAttrs.version}";
    hash = "sha256-199CjhOdC0BnNyhhTSn/DWmqn/0vSziV+aW2shE1Vuo=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    gsl
    libdivsufsort
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [ llvmPackages.openmp ];

  configureFlags = [ (lib.enableFeature finalAttrs.finalPackage.doCheck "unit-tests") ];
  doCheck = true;
  nativeCheckInputs = [ glib ];

  preCheck = ''
    patchShebangs ./test
  '';

  meta = {
    description = "Efficient Estimation of Evolutionary Distances";
    homepage = "https://github.com/evolbioinf/andi";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ natsukium ];
    platforms = lib.platforms.all;
    mainProgram = "andi";
  };
})
