{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  binlore,
  esh,
  gawk,
  gnused,
  runtimeShell,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "esh";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "jirutka";
    repo = "esh";
    rev = "v${finalAttrs.version}";
    sha256 = "1ddaji5nplf1dyvgkrhqjy8m5djaycqcfhjv30yprj1avjymlj6w";
  };

  postPatch = ''
    patchShebangs .
    substituteInPlace esh \
        --replace '"/bin/sh"' '"${runtimeShell}"' \
        --replace '"awk"' '"${gawk}/bin/awk"' \
        --replace 'sed' '${gnused}/bin/sed'
    substituteInPlace tests/test-dump.exp \
        --replace '#!/bin/sh' '#!${runtimeShell}'
  '';

  nativeBuildInputs = [ asciidoctor ];

  buildInputs = [
    gawk
    gnused
  ];

  makeFlags = [
    "prefix=$(out)"
    "DESTDIR="
  ];

  doCheck = true;
  checkTarget = "test";

  # working around a bug in file. Was fixed in
  # file 5.41-5.43 but regressed in 5.44+
  # see https://bugs.astron.com/view.php?id=276
  # "can" verdict because of `-s SHELL` arg
  passthru.binlore.out = binlore.synthesize esh ''
    execer can bin/esh
  '';

  meta = {
    description = "Simple templating engine based on shell";
    homepage = "https://github.com/jirutka/esh";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mnacamura ];
    platforms = lib.platforms.unix;
    mainProgram = "esh";
  };
})
