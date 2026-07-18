{
  lib,
  stdenv,
  fetchFromGitHub,
  buildFHSEnv,
  expat,
  gitMinimal,
  libevent,
  ocl-icd,
  openssl,
  re2,
  scons,
  versionCheckHook,
  zlib,
  extraPkgs ? [ ],
}:
let
  pname = "fah-client";
  version = "8.5.6";

  cbangSrc = fetchFromGitHub {
    hash = "sha256-oh3q/gmAKx8BHoaw6Dxkd0GoxYyJ6is8uCKcivQVv2g=";
    owner = "cauldrondevelopmentllc";
    repo = "cbang";
    tag = "bastet-v${version}";
  };

  fah-client = stdenv.mkDerivation {
    inherit pname version;

    src = fetchFromGitHub {
      owner = "FoldingAtHome";
      repo = "fah-client-bastet";
      tag = "v${version}";
      hash = "sha256-B5h2eXSCvYG5juNkBRBh+KUsm26O9JTI1S7yKkHgZ7c=";
    };

    strictDeps = true;

    nativeBuildInputs = [
      gitMinimal
      libevent
      re2
      scons
    ];

    buildInputs = [ openssl ];

    preBuild = ''
      scons -C $CBANG_HOME
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,share/applications}

      cp fah-client $out/bin/fah-client

      cp install/lin/fah-client.desktop.in $out/share/applications/fah-client.desktop
      sed \
        -e "s|Icon=.*|Icon=$out/share/feh-client/images/fahlogo.png|g" \
        -e "s|%(PACKAGE_URL)s|https://github.com/FoldingAtHome/fah-client-bastet|g" \
        -i $out/share/applications/fah-client.desktop

      runHook postInstall
    '';

    doInstallCheck = true;

    nativeInstallCheckInputs = [
      versionCheckHook
    ];

    __structuredAttrs = true;

    postUnpack = ''
      export CBANG_HOME=$NIX_BUILD_TOP/cbang

      cp -r --no-preserve=mode ${cbangSrc} $CBANG_HOME
    '';

  };
in
buildFHSEnv {
  inherit pname version;
  runScript = "/bin/fah-client";

  targetPkgs =
    _:
    [
      fah-client
      ocl-icd
      zlib
      expat
    ]
    ++ extraPkgs;

  meta = {
    description = "Folding@home client";
    homepage = "https://foldingathome.org/";
    license = lib.licenses.gpl3;
    maintainers = [ lib.maintainers.GaetanLepage ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "fah-client";
  };
}
