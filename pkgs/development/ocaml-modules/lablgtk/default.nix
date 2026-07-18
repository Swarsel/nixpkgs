{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  camlp-streams,
  fetchpatch,
  findlib,
  gtk2,
  gtksourceview,
  libgnomecanvas,
  ocaml,
  pkg-config,
}:

let
  param =
    let
      check = lib.versionAtLeast ocaml.version;
    in
    if check "4.06" then
      rec {
        version = "2.18.13";

        src = fetchFromGitHub {
          owner = "garrigue";
          repo = "lablgtk";
          rev = version;
          sha256 = "sha256-69Svno0qLaUifMscnVuPUJlCo9d8Lee+1qiYx34G3Po=";
        };

        buildInputs = [ camlp-streams ];
        env = { };
      }
    else if check "3.12" then
      {
        version = "2.18.5";

        src = fetchurl {
          url = "https://forge.ocamlcore.org/frs/download.php/1627/lablgtk-2.18.5.tar.gz";
          sha256 = "0cyj6sfdvzx8hw7553lhgwc0krlgvlza0ph3dk9gsxy047dm3wib";
        };

        # Workaround build failure on -fno-common toolchains like upstream
        # gcc-10. Otherwise build fails as:
        #   ld: ml_gtktree.o:(.bss+0x0): multiple definition of
        #     `ml_table_extension_events'; ml_gdkpixbuf.o:(.bss+0x0): first defined here
        env.NIX_CFLAGS_COMPILE = "-fcommon";
      }
    else
      throw "lablgtk is not available for OCaml ${ocaml.version}";
in

stdenv.mkDerivation {
  inherit (param) version src env;
  pname = "ocaml${ocaml.version}-lablgtk";

  # https://github.com/garrigue/lablgtk/issues/162
  patches = [
    (fetchpatch {
      hash = "sha256-jxmcAIIpdee7sPKfeLAijBnwgKDTjXuiWlh6c9rs+18=";
      url = "https://github.com/garrigue/lablgtk/commit/c9717249954d1713815d435c84f9953a685af4be.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    ocaml
    findlib
  ];

  buildInputs = [
    gtk2
    libgnomecanvas
    gtksourceview
  ]
  ++ param.buildInputs or [ ];

  configureFlags = [ "--with-libdir=$(out)/lib/ocaml/${ocaml.version}/site-lib" ];
  buildFlags = [ "world" ];

  preInstall = ''
    mkdir -p $out/lib/ocaml/${ocaml.version}/site-lib
    export OCAMLPATH=$out/lib/ocaml/${ocaml.version}/site-lib/:$OCAMLPATH
  '';

  dontStrip = true;

  meta = {
    inherit (ocaml.meta) platforms;
    description = "OCaml interface to GTK";
    homepage = "http://lablgtk.forge.ocamlcore.org/";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      roconnor
      vbgl
    ];

    mainProgram = "lablgtk2";
  };
}
