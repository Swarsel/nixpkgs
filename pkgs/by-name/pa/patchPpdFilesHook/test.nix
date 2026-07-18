{
  lib,
  stdenv,
  diffutils,
  patchPpdFilesHook,
  replaceVars,
}:

let
  inherit (lib.meta) getExe';

  input = replaceVars ./test.ppd {
    keep = "cmp";
    patch = "cmp";
    pathkeep = "/bin/cmp";
    pathpatch = "/bin/cmp";
  };

  output = replaceVars ./test.ppd {
    keep = "cmp";
    patch = getExe' diffutils "cmp";
    pathkeep = "/bin/cmp";
    pathpatch = getExe' diffutils "cmp";
  };
in

stdenv.mkDerivation {
  nativeBuildInputs = [
    diffutils
    patchPpdFilesHook
  ];

  buildInputs = [ diffutils ];

  preFixup = ''
    install -D "${input}" "${placeholder "out"}/share/cups/model/test.ppd"
    install -D "${input}" "${placeholder "out"}/share/ppd/test.ppd"
  '';

  postFixup = ''
    diff --color --report-identical-files "${output}" "${placeholder "out"}/share/cups/model/test.ppd"
    diff --color --report-identical-files "${output}" "${placeholder "out"}/share/ppd/test.ppd"
  '';

  dontInstall = true;
  dontUnpack = true;
  name = "${patchPpdFilesHook.name}-test";
  ppdFileCommands = [ "cmp" ];
}
