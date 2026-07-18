{
  lib,
  stdenv,
  aflplusplus,
}:

stdenv.mkDerivation {
  pname = "libdislocator";
  version = lib.getVersion aflplusplus;
  src = aflplusplus.src;
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  preInstall = ''
    mkdir -p $out/lib/afl
  '';

  postInstall = ''
    mkdir $out/bin
    cat > $out/bin/get-libdislocator-so <<END
    #!${stdenv.shell}
    echo $out/lib/afl/libdislocator.so
    END
    chmod +x $out/bin/get-libdislocator-so
  '';

  postUnpack = "chmod -R +w ${aflplusplus.src.name}";
  sourceRoot = "${aflplusplus.src.name}/utils/libdislocator";

  meta = {
    description = ''
      Drop-in replacement for the libc allocator which improves
      the odds of bumping into heap-related security bugs in
      several ways
    '';

    homepage = "https://github.com/vanhauser-thc/AFLplusplus";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      ris
      msanft
    ];
  };
}
