{
  lib,
  stdenv,
  fetchzip,
  jdk,
  makeDesktopItem,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "visualvm";
  version = "2.2.1";

  src = fetchzip {
    url = "https://github.com/visualvm/visualvm.src/releases/download/${finalAttrs.version}/visualvm_${
      builtins.replaceStrings [ "." ] [ "" ] finalAttrs.version
    }.zip";

    sha256 = "sha256-4Ub14FKOp2toMMuIaWJZ2pvE34UJ4m++Psoh8KdCe2M=";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    find . -type f -name "*.dll" -o -name "*.exe"  -delete;

    substituteInPlace etc/visualvm.conf \
      --replace "#visualvm_jdkhome=" "visualvm_jdkhome=" \
      --replace "/path/to/jdk" "${jdk.home}" \

    cp -r . $out
  '';

  desktopItem = makeDesktopItem {
    categories = [ "Development" ];
    comment = "Java Troubleshooting Tool";
    desktopName = "VisualVM";
    exec = "visualvm";
    genericName = "Java Troubleshooting Tool";
    name = "visualvm";
  };

  meta = {
    description = "Visual interface for viewing information about Java applications";

    longDescription = ''
      VisualVM is a visual tool integrating several commandline JDK
      tools and lightweight profiling capabilities. Designed for both
      production and development time use, it further enhances the
      capability of monitoring and performance analysis for the Java
      SE platform.
    '';

    homepage = "https://visualvm.github.io";

    license = with lib.licenses; [
      gpl2Plus
      classpathException20
    ];

    maintainers = with lib.maintainers; [
      michalrus
      moaxcp
    ];

    platforms = lib.platforms.all;
    mainProgram = "visualvm";
  };
})
