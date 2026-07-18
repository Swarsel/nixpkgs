{
  lib,
  base64,
  buildDunePackage,
  cmdliner,
  coreutils,
  digestif,
  git-unix,
  imagemagick,
  kicadsch,
  lwt,
  lwt_ppx,
  replaceVars,
  sha,
  tyxml,
}:

buildDunePackage {
  inherit (kicadsch) src version;
  pname = "plotkicadsch";

  patches = [
    (replaceVars ./fix-paths.patch {
      inherit coreutils imagemagick;
    })
  ];

  buildInputs = [
    base64
    cmdliner
    digestif
    git-unix
    kicadsch
    lwt
    lwt_ppx
    sha
    tyxml
  ];

  duneVersion = "3";
  minimalOCamlVersion = "4.09";

  meta = {
    description = "Tool to export Kicad Sch files to SVG pictures";
    homepage = "https://github.com/jnavila/plotkicadsch";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ leungbk ];
  };
}
