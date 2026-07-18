{
  lib,
  emptyDirectory,
  emptyFile,
  figlet,
  hello,
  runCommand,
  writeText,
  zlib,
}:
{
  inherit
    figlet
    hello
    zlib
    ;

  inherit
    emptyFile
    emptyDirectory
    ;

  helloFigletRef = writeText "hi" "hello ${hello} ${figlet}";
  helloRef = writeText "hi" "hello ${hello}";
  helloRefDup = writeText "hi" "hello ${hello}";
  norefs = writeText "hi" "hello";
  norefsDup = writeText "hi" "hello";
  path = ./apath.txt;
  pathLike.outPath = ./apath.txt;
  selfRef = runCommand "self-ref-1" { } "echo $out >$out";
  selfRef2 = runCommand "self-ref-2" { } ''echo "${figlet}, $out" >$out'';
  zlib-dev = zlib.dev;
}
