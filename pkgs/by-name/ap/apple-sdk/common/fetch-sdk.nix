{
  lib,
  fetchurl,
  cpio,
  pbzx,
}:

{
  hash,
  urls,
  version,
}:

fetchurl {
  inherit version urls hash;
  pname = "macOS-SDK";

  nativeBuildInputs = [
    cpio
    pbzx
  ];

  postFetch = ''
    renamed=$(mktemp -d)/sdk.xar
    mv "$downloadedFile" "$renamed"
    pbzx "$renamed" | cpio -idm

    src=Library/Developer/CommandLineTools/SDKs/MacOSX${lib.versions.majorMinor version}.sdk

    # Remove unwanted binaries, man pages, and folders from the SDK.
    rm -rf $src/usr/bin $src/usr/share $src/System/Library/Perl

    mkdir -p "$out"
    cp -rd $src/* "$out"
  '';

  recursiveHash = true;
}
