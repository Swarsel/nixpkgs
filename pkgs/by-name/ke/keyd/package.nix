{
  lib,
  stdenv,
  fetchFromGitHub,
  nixosTests,
  python3Packages,
  runtimeShell,
  versionCheckHook,
}:
let
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "rvaiya";
    repo = "keyd";
    rev = "v" + version;
    hash = "sha256-l7yjGpicX1ly4UwF7gcOTaaHPRnxVUMwZkH70NDLL5M=";
  };

  appMap = python3Packages.buildPythonApplication (finalAttrs: {
    inherit version src;
    pname = "keyd-application-mapper";

    postPatch = ''
      substituteInPlace scripts/${finalAttrs.pname} \
        --replace-fail /bin/sh ${runtimeShell}
    '';

    propagatedBuildInputs = with python3Packages; [
      python-xlib
      pygobject3.out
      dbus-python.out
    ];

    installPhase = ''
      install -Dm555 -t $out/bin scripts/${finalAttrs.pname}
    '';

    dontBuild = true;
    pyproject = false;
    meta.mainProgram = "keyd-application-mapper";
  });

in
stdenv.mkDerivation {
  inherit version src;
  pname = "keyd";

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail /usr/local ""

    substituteInPlace keyd.service.in \
      --replace-fail @PREFIX@ $out
  '';

  postInstall = ''
    ln -sf ${lib.getExe appMap} $out/bin/${appMap.pname}
    rm -rf $out/etc
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  enableParallelBuilding = true;
  installFlags = [ "DESTDIR=${placeholder "out"}" ];
  passthru.tests.keyd = nixosTests.keyd;

  meta = {
    description = "Key remapping daemon for Linux";
    homepage = "https://github.com/rvaiya/keyd";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ alfarel ];
    platforms = lib.platforms.linux;
    mainProgram = "keyd";
  };
}
