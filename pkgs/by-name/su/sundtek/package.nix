{
  lib,
  stdenv,
  fetchurl,
}:
let
  version = "2016-01-26";
  rpath = lib.makeLibraryPath [
    "$out/lib"
    "$out/bin"
  ];
  platform =
    with stdenv;
    if isx86_64 then
      "64bit"
    else if isi686 then
      "32bit"
    else
      throw "${system} not considered in build derivation. Might still be supported.";
  sha256 =
    with stdenv;
    if isx86_64 then
      "1jfsng5n3phw5rqpkid9m5j7m7zgj5bifh7swvba7f97y6imdaax"
    else
      "15y6r5w306pcq4g1rn9f7vf70f3a7qhq237ngaf0wxh2nr0aamxp";
in
stdenv.mkDerivation {
  inherit version;
  pname = "sundtek";

  src = fetchurl {
    url = "http://www.sundtek.de/media/netinst/${platform}/installer.tar.gz";
    sha256 = sha256;
  };

  installPhase = ''
    cp -r opt $out

    # add and fix pkg-config file
    mkdir -p $out/lib/pkgconfig
    substitute $out/doc/libmedia.pc $out/lib/pkgconfig/libmedia.pc \
      --replace /opt $out
  '';

  postFixup = ''
    find $out -type f -exec \
      patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" {} \
      patchelf --set-rpath ${rpath} {} \;
  '';

  preferLocalBuild = true;
  sourceRoot = ".";

  meta = {
    description = "Sundtek MediaTV driver";
    homepage = "https://support.sundtek.com/index.php/topic,1573.0.html";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.simonvandel ];
    platforms = lib.platforms.unix;
  };
}
