{
  lib,
  stdenv,
  fetchFromGitHub,
  gitMinimal,
  meson,
  ninja,
  pkg-config,
  python3Packages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "boxfort";
  version = "0.1.5";

  src = fetchFromGitHub {
    owner = "Snaipe";
    repo = "BoxFort";
    rev = "v${finalAttrs.version}";
    hash = "sha256-fgX2Ilb01qa9myuz6yiC67WKeai2m/csncS6u5and3o=";
  };

  outputs = [
    "dev"
    "out"
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    gitMinimal
  ];

  preConfigure = ''
    patchShebangs ci/isdir.py
  '';

  doCheck = true;
  nativeCheckInputs = with python3Packages; [ cram ];

  meta = {
    description = "Convenient & cross-platform sandboxing C library";
    homepage = "https://github.com/Snaipe/BoxFort";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      sigmanificient
      thesola10
      Yumasi
    ];

    platforms = lib.platforms.unix;
  };
})
