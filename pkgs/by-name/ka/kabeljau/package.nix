{
  lib,
  bash,
  dialog,
  fetchFromCodeberg,
  imagemagick,
  just,
  makeWrapper,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation rec {
  pname = "kabeljau";
  version = "2.1.0";

  src = fetchFromCodeberg {
    owner = "annaaurora";
    repo = "kabeljau";
    rev = "v${version}";
    hash = "sha256-yZHDnzNTdDXHR+Pi3NODqw4npzuthHgOJYnTmIvGyUE=";
  };

  postPatch = ''
    patchShebangs --host ${pname}
  '';

  # Inkscape is needed in a just recipe where it is used to export the SVG icon to several different sized PNGs.
  nativeBuildInputs = [
    just
    imagemagick
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    just --set bin-path $out/bin --set share-path $out/share linux-install
    wrapProgram $out/bin/${pname} --suffix PATH : ${lib.makeBinPath [ dialog ]}

    runHook postInstall
  '';

  meta = {
    description = "Survive as a stray cat in an ncurses game";
    homepage = "https://codeberg.org/annaaurora/kabeljau";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ annaaurora ];
    mainProgram = "kabeljau";
  };
}
