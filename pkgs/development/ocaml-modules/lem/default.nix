{
  lib,
  stdenv,
  fetchFromGitHub,
  findlib,
  makeWrapper,
  num,
  ocaml,
  ocamlbuild,
  zarith,
}:

stdenv.mkDerivation rec {
  pname = "ocaml${ocaml.version}-lem";
  version = "2025-03-13";

  src = fetchFromGitHub {
    owner = "rems-project";
    repo = "lem";
    rev = version;
    hash = "sha256-ZV2OiFonMlNzqtsumMQ8jzY9/ATaZxiNHZ7JzOfGluY=";
  };

  nativeBuildInputs = [
    makeWrapper
    ocamlbuild
    findlib
    ocaml
  ];

  propagatedBuildInputs = [
    zarith
    num
  ];

  postInstall = ''
    wrapProgram $out/bin/lem --set LEMLIB $out/share/lem/library
  '';

  createFindlibDestdir = true;
  installFlags = [ "INSTALL_DIR=$(out)" ];

  meta = {
    description = "Tool for lightweight executable mathematics";
    homepage = "https://github.com/rems-project/lem";

    license = with lib.licenses; [
      bsd3
      gpl2
    ];

    maintainers = [ ];
    platforms = ocaml.meta.platforms;
    mainProgram = "lem";
    broken = !(lib.versionAtLeast ocaml.version "4.07");
  };
}
