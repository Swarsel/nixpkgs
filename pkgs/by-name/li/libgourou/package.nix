{
  lib,
  stdenv,
  curl,
  fetchFromGitea,
  installShellFiles,
  libzip,
  openssl,
  pugixml,
  updfparser,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libgourou";
  version = "0.8.9";

  src = fetchFromGitea {
    owner = "soutade";
    repo = "libgourou";
    tag = "v${finalAttrs.version}";
    hash = "sha256-KwDpyWtEsXacCcCbj0QlNucOy/S62NiPocf+G7YINwU=";
    domain = "forge.soutade.fr";
  };

  postPatch = ''
    patchShebangs scripts/setup.sh
  '';

  nativeBuildInputs = [ installShellFiles ];

  buildInputs = [
    pugixml
    updfparser
    curl
    openssl
    libzip
  ];

  makeFlags = [
    "BUILD_STATIC=1"
    "BUILD_SHARED=1"
  ];

  postConfigure = ''
    mkdir lib
    ln -s ${updfparser}/lib lib/updfparser
  '';

  installPhase = ''
    runHook preInstall
    install -Dt $out/include include/libgourou*.h
    install -Dt $out/lib libgourou.so
    install -Dt $out/lib libgourou.so.${finalAttrs.version}
    install -Dt $out/lib libgourou.a
    install -Dt $out/bin utils/acsmdownloader
    install -Dt $out/bin utils/adept_{activate,loan_mgt,remove}
    installManPage utils/man/*.1
    runHook postInstall
  '';

  meta = {
    description = "Implementation of Adobe's ADEPT protocol for ePub/PDF DRM";
    homepage = "https://forge.soutade.fr/soutade/libgourou";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ autumnal ];
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
