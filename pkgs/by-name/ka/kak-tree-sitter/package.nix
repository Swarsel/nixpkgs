{
  lib,
  kak-tree-sitter-unwrapped,
  makeWrapper,
  symlinkJoin,
  tinycc,
}:

symlinkJoin (finalAttrs: {
  inherit (kak-tree-sitter-unwrapped) version;
  inherit (kak-tree-sitter-unwrapped) meta;
  pname = lib.replaceStrings [ "-unwrapped" ] [ "" ] kak-tree-sitter-unwrapped.pname;
  nativeBuildInputs = [ makeWrapper ];

  # Tree-Sitter grammars are C programs that need to be compiled
  # Use tinycc as cc to reduce closure size
  postBuild = ''
    mkdir -p $out/libexec/tinycc/bin
    ln -s ${lib.getExe tinycc} $out/libexec/tinycc/bin/cc
    wrapProgram "$out/bin/ktsctl" \
      --suffix PATH : $out/libexec/tinycc/bin
  '';

  name = "${finalAttrs.pname}-${finalAttrs.version}";
  paths = [ kak-tree-sitter-unwrapped ];
})
