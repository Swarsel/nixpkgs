{
  lib,
  fetchzip,
  sbcl,
  stdenvNoCC,
  installConcurrency ? true,
  installLogicLab ? true,
  installStandardLibrary ? true,
  installThorn ? true,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "shen-sbcl";
  version = "41.2";

  src = fetchzip {
    url = "https://shenlanguage.org/Download/S${finalAttrs.version}.zip";
    hash = "sha256-hgO/g0XefSXn5pjiV5LzGmoZ8nsqmZcyZpK6nbcE0es=";
  };

  postPatch = ''
    # allow SBCL to define *release* global
    substituteInPlace Primitives/globals.lsp \
      --replace-fail '"2.0.0"' '(LISP-IMPLEMENTATION-VERSION)'

    # remove interactive prompts during image creation
    # shen/tk requires further configuration and isn't supported by default
    substituteInPlace Lib/install.shen \
      --replace-fail '(y-or-n? "install standard library?")' '${lib.boolToString installStandardLibrary}' \
      --replace-fail '(y-or-n? "install concurrency? (required for Shen/tk)")' '${lib.boolToString installConcurrency}' \
      --replace-fail '(y-or-n? "install Shen/tk + IDE?")' 'false' \
      --replace-fail '(y-or-n? "install THORN?")' '${lib.boolToString installThorn}' \
      --replace-fail '(y-or-n? "install Logic Lab?")' '${lib.boolToString installLogicLab}'
  '';

  strictDeps = true;
  nativeBuildInputs = [ sbcl ];

  buildPhase = ''
    runHook preBuild

    sbcl --noinform --no-sysinit --no-userinit --load install.lsp

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 sbcl-shen.exe $out/bin/shen-sbcl

    runHook postInstall
  '';

  dontStrip = true; # necessary to prevent runtime errors with sbcl

  meta = {
    description = "Port of Shen running on Steel Bank Common Lisp";
    homepage = "https://shenlanguage.org";
    changelog = "https://shenlanguage.org/download.html#kernel";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ hakujin ];
    platforms = sbcl.meta.platforms;
    mainProgram = "shen-sbcl";
  };
})
