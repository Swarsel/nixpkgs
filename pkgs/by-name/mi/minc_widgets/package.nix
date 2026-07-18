{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  coreutils,
  fetchpatch,
  libminc,
  makeWrapper,
  minc_tools,
  octave,
  perlPackages,
}:

stdenv.mkDerivation {
  pname = "minc-widgets";
  version = "unstable-2016-04-20";

  src = fetchFromGitHub {
    owner = "BIC-MNI";
    repo = "minc-widgets";
    rev = "f08b643894c81a1a2e0fbfe595a17a42ba8906db";
    sha256 = "1b9g6lf37wpp211ikaji4rf74rl9xcmrlyqcw1zq3z12ji9y33bm";
  };

  patches = [
    (fetchpatch {
      hash = "sha256-qqMKbxQS+HTRQaOP2DH/m8Z3DqoCMGLFp1AEKaQ6l5s=";
      name = "cmake4-fix.patch";
      url = "https://github.com/BIC-MNI/minc-widgets/commit/9f5bc1996d2f9b4702efdb010834e2c7f1e3fbf1.patch";
    })
  ];

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [ libminc ];

  propagatedBuildInputs =
    (with perlPackages; [
      perl
      GetoptTabular
      MNI-Perllib
    ])
    ++ [
      octave
      coreutils
      minc_tools
    ];

  postFixup = ''
    for p in $out/bin/*; do
      wrapProgram $p --prefix PERL5LIB : $PERL5LIB --set PATH "${
        lib.makeBinPath [
          coreutils
          minc_tools
        ]
      }";
    done
  '';

  meta = {
    description = "Collection of Perl and shell scripts for processing MINC files";
    homepage = "https://github.com/BIC-MNI/minc-widgets";
    license = lib.licenses.free;
    maintainers = with lib.maintainers; [ bcdarwin ];
    platforms = lib.platforms.unix;
  };
}
