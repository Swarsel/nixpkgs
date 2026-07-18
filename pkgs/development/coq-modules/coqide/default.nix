{
  lib,
  adwaita-icon-theme,
  copyDesktopItems,
  coq,
  glib,
  makeDesktopItem,
  mkCoqDerivation,
  wrapGAppsHook3,
  version ? null,
}:

mkCoqDerivation rec {
  inherit version;
  inherit (coq) src;
  pname = "coqide";

  buildInputs = [
    copyDesktopItems
    wrapGAppsHook3
    coq.ocamlPackages.lablgtk3-sourceview3
    glib
    adwaita-icon-theme
  ];

  preConfigure = ''
    patchShebangs dev/tools/
  '';

  buildPhase = ''
    runHook preBuild
    dune build -p ${pname} -j $NIX_BUILD_CORES
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    dune install --prefix $out ${pname}
    runHook postInstall
  '';

  defaultVersion = if lib.versions.range "8.14" "8.20" coq.version then coq.version else null;

  desktopItems = [
    (makeDesktopItem {
      categories = [
        "Development"
        "Science"
        "Math"
        "IDE"
        "GTK"
      ];

      comment = "Graphical interface for the Coq proof assistant";
      desktopName = "CoqIDE";
      exec = "coqide";
      icon = "coq";
      name = "coqide";
    })
  ];

  prefixKey = "-prefix ";
  release."${coq.version}" = { };
  useDune = true;

  meta = {
    description = "CoqIDE user interface for the Coq proof assistant";
    homepage = "https://coq.inria.fr";
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.Zimmi48 ];
    mainProgram = "coqide";
  };
}
