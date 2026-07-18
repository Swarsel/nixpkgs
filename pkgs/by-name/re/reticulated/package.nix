{
  lib,
  fetchFromGitHub,
  nix-update-script,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "reticulated";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "RFnexus";
    repo = "reticulated";
    tag = "v${finalAttrs.version}";
    hash = "sha256-02vdSKAEb59VucoDe5M+uSiNdyMybfQnhCr+LzGyNT0=";
  };

  postPatch = ''
    substituteInPlace sim/config.py \
      --replace-fail 'os.path.join(BASE_DIR, "web")' '"${placeholder "out"}/share/web"'
  '';

  # No --version flag and no Python tests
  doCheck = false;

  postInstall = ''
    mkdir -p "$out/share"
    cp -r web "$out/share/"
  '';

  postFixup = ''
    wrapProgram $out/bin/reticulated \
      --set PYTHONPATH $PYTHONPATH \
      --set SIM_DATA_DIR "/tmp"
  '';

  __structuredAttrs = true;

  build-system = with python3Packages; [
    setuptools
  ];

  dependencies = with python3Packages; [
    fastapi
    lxmf
    rns
    uvicorn
    websockets
  ];

  pyproject = true;
  pythonImportsCheck = [ "sim" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Reticulum Network Stack Simulator";
    homepage = "https://github.com/RFnexus/reticulated";
    changelog = "https://github.com/RFnexus/reticulated/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ drupol ];
    platforms = lib.platforms.all;
    mainProgram = "reticulated";
  };
})
