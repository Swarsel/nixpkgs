{
  stdenv,
  ucg,
}:

stdenv.mkDerivation {
  inherit (ucg) version;
  pname = "ucg-test";
  nativeBuildInputs = [ ucg ];

  buildCommand = ''
    testFile=$(mktemp /tmp/ucg-test.XXXX)
    echo -ne 'Lorem ipsum dolor sit amet\n2.7182818284590' > $testFile
    ucg 'dolor' $testFile || { rm $testFile; exit -1; }
    ucg --ignore-case 'lorem' $testFile || { rm $testFile; exit -1; }
    ucg --word-regexp '2718' $testFile && { rm $testFile; exit -1; }
    ucg 'pisum' $testFile && { rm $testFile; exit -1; }
    rm $testFile
    touch $out
  '';

  dontInstall = true;
  meta.timeout = 10;
}
