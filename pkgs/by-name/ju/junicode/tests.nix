{
  lib,
  junicode,
  runCommand,
  texliveBasic,
}:
let
  texliveWithJunicode = texliveBasic.withPackages (p: [
    p.xetex
    junicode
  ]);

  texTest =
    {
      file,
      fonttype,
      package,
      tex,
    }:
    lib.attrsets.nameValuePair "${package}-${tex}-${fonttype}" (
      runCommand "${package}-test-${tex}-${fonttype}.pdf"
        {
          inherit tex fonttype file;
          nativeBuildInputs = [ texliveWithJunicode ];
        }
        ''
          substituteAll $file test.tex
          HOME=$PWD $tex test.tex
          cp test.pdf $out
        ''
    );
in
builtins.listToAttrs (
  lib.mapCartesianProduct texTest {
    file = [ ./test.tex ];

    fonttype = [
      "ttf"
      "otf"
    ];

    package = [ "junicode" ];

    tex = [
      "xelatex"
      "lualatex"
    ];
  }
  ++ [
    (texTest {
      file = ./test-vf.tex;
      fonttype = "ttf";
      package = "junicodevf";
      tex = "lualatex";
    })
  ]
)
