{
  lib,
  stdenv,
  fetchurl,
  brand,
  bubblewrap,
  dpkg,
  hash,
  homepage,
  runCommand,
  runtimeShell,
  type,
  url,
  version,
  vmTools,
  ...
}:
let
  debian =
    let
      debs = lib.flatten (import ./deps.nix { inherit fetchurl; });
    in
    runCommand "x32edit-debian" { nativeBuildInputs = [ dpkg ]; } (
      lib.concatMapStringsSep "\n" (deb: ''
        dpkg-deb -x ${deb} $out
      '') debs
    );
in
stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "${lib.toLower type}-edit";

  src = fetchurl {
    inherit url hash;
  };

  installPhase = ''
    mkdir -p $out/bin
    cp ${type}-Edit $out/bin/.${finalAttrs.pname}

    cat >$out/bin/${finalAttrs.pname} <<EOF
    #!${runtimeShell} -eu
    exec ${lib.getExe bubblewrap} \
      --dev-bind / / \
      --ro-bind "${debian}/lib" /lib \
      --ro-bind "${debian}/lib64" /lib64 \
      --tmpfs /usr \
      --ro-bind "${debian}/usr/lib" /usr/lib \
      $out/bin/.${finalAttrs.pname}
    EOF
    chmod 755 $out/bin/${finalAttrs.pname}
  '';

  dontBuild = true;
  dontStrip = true;
  sourceRoot = ".";

  passthru.deps =
    let
      distro = vmTools.debDistros.debian12x86_64;
    in
    vmTools.debClosureGenerator {
      inherit (distro) urlPrefix;
      name = "x32edit-dependencies";

      packages = [
        "libstdc++6"
        "libcurl4"
        "libfreetype6"
        "libasound2"
        "libx11-6"
        "libxext6"
      ];

      packagesLists = [ distro.packagesLists ];
    };

  meta = {
    inherit homepage;
    description = "Editor for the ${brand} ${type} digital mixer";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ magnetophon ];
    platforms = lib.platforms.linux;
  };
})
