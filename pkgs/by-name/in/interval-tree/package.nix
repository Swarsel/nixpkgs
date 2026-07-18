{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "interval-tree";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "5cript";
    repo = "interval-tree";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t1/oTr+sYkpTiDzaM4SxUcWzO3r24EkUJO04TYNLcQQ=";
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/
    cp -r $src/include/ $out/

    runHook postInstall
  '';

  __structuredAttrs = true;
  # interval-tree is a header only library
  dontBuild = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "C++ header only interval tree implementation";
    homepage = "https://github.com/5cript/interval-tree";
    license = lib.licenses.cc0;
    maintainers = with lib.maintainers; [ aiyion ];
    platforms = lib.platforms.all;
  };
})
