{
  lib,
  stdenv,
  formats,
  glibcLocales,
  jdk,
}:

# This test primarily tests correct escaping.
# See also testJavaProperties in
# pkgs/pkgs-lib/tests/formats.nix, which tests
# type coercions and is a bit easier to read.

let
  inherit (lib) concatStrings attrValues mapAttrs;

  javaProperties = formats.javaProperties { };

  input = {
    "" = "empty key's value";
    "!" = "not a comment!";
    "!a" = "still not! a comment";
    "!b" = "still not ! a comment";
    "#" = "not a comment # still not";
    "1" = "2 3";
    "a \t\nb" = " c";
    "all stuff" = "foo = bar";

    "angry \t\nkey" = ''
      multi
      ${"\tline\r"}
       space-
        indented
      trailing-space${" "}
      trailing-space${"  "}
      value
    '';

    "dos paths" = "C:\\Program Files\\Nix For Windows\\nix.exe";
    "empty value" = "";
    foo = "bar";
    "nor = this" = "bad";
    "this=not" = "bad";
    "typical.dot.syntax" = "com.sun.awt";
    "unicode big brain" = "e = mc□";
    "ütf-8" = "dûh";
    # NB: Some editors (vscode) show this _whole_ line in right-to-left order
    "الجبر" = "أكثر من مجرد أرقام";
  };

in
stdenv.mkDerivation {
  src = lib.sources.sourceByGlobs ./. [
    "**/*.java"
  ];

  nativeBuildInputs = [
    jdk
    glibcLocales
  ];

  # On Linux, this can be C.UTF-8, but darwin + zulu requires en_US.UTF-8
  env.LANG = "en_US.UTF-8";

  buildPhase = ''
    javac Main.java
  '';

  doCheck = true;

  checkPhase = ''
    cat -v $properties
    java Main $properties >actual
    diff -U3 $expectedPath actual
  '';

  installPhase = "touch $out";

  expected = concatStrings (
    attrValues (
      mapAttrs (key: value: ''
        KEY
        ${key}
        VALUE
        ${value}

      '') input
    )
  );

  name = "pkgs.formats.javaProperties-test-${jdk.name}";
  # Expected output as printed by Main.java
  passAsFile = [ "expected" ];
  # technically should go through the type.merge first, but that's tested
  # in tests/formats.nix.
  properties = javaProperties.generate "example.properties" input;
}
