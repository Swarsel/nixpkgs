{
  stdenv,
  criterion,
  pkg-config,
}:
stdenv.mkDerivation rec {
  inherit (criterion) version;
  src = ./test_dummy.c;
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ criterion ];

  buildPhase = ''
    cc -o ${name} $src `pkg-config --libs criterion`
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${name} $out/bin/${name}
  '';

  dontUnpack = true;
  name = "version-tester";
  meta.mainProgram = name;
}
