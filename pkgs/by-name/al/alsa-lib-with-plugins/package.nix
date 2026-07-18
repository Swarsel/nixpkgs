{
  lib,
  alsa-lib,
  lndir,
  pkgs,
  runCommand,
  symlinkJoin,
  plugins ? [ pkgs.alsa-plugins ],
}:
let
  merged = symlinkJoin {
    name = "alsa-plugins-merged";
    paths = plugins;
  };
in
runCommand "${alsa-lib.pname}-${alsa-lib.version}"
  {
    inherit (alsa-lib) pname version;
    outputs = alsa-lib.outputs;

    meta = {
      description = "Wrapper to ease access to ALSA plugins";
      platforms = lib.platforms.linux;
      mainProgram = "aserver";
    };
  }
  (
    (lib.concatMapStringsSep "\n" (output: ''
      mkdir ${placeholder output}
      ${lndir}/bin/lndir ${lib.attrByPath [ output ] null alsa-lib} \
        ${placeholder output}
    '') alsa-lib.outputs)
    + ''
      cp -r ${merged}/lib/alsa-lib $out/lib
      (
        echo $out | wc -c
        echo ${alsa-lib} | wc -c
      ) | xargs echo | grep -q "^\(.*\) \1$" || (
        echo cannot binary patch
        exit 1
      )
      rm $out/lib/libasound.la
      rm $out/lib/libasound.so.?.?.?
      rm $dev/lib/pkgconfig/alsa.pc
      rm $dev/nix-support/propagated-build-inputs
      cp ${alsa-lib}/lib/libasound.la $out/lib
      cp ${alsa-lib}/lib/libasound.so.?.?.? $out/lib
      cp ${alsa-lib.dev}/lib/pkgconfig/alsa.pc $dev/lib/pkgconfig
      cp ${alsa-lib.dev}/nix-support/propagated-build-inputs $dev/nix-support
      sed -i \
          $out/lib/libasound.la \
          $out/lib/libasound.so.?.?.? \
          $dev/lib/pkgconfig/alsa.pc \
          $dev/nix-support/propagated-build-inputs \
        -e "s@${alsa-lib}@$out@g"
    ''
  )
