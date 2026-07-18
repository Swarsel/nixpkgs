{
  lib,
  stdenv,
  fetchurl,
  cmake,
  openssl,
  platformAttrs,
  version,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  inherit version;
  pname = "hadoop-yarn-containerexecutor";

  src = fetchurl {
    url = "mirror://apache/hadoop/common/hadoop-${finalAttrs.version}/hadoop-${finalAttrs.version}-src.tar.gz";
    hash = platformAttrs.${stdenv.system}.srcHash;
  };

  postPatch = ''
    sed -i -r 's/(cmake_minimum_required\(VERSION) [0-9.]+/\1 3.10/' CMakeLists.txt
  '';

  nativeBuildInputs = [ cmake ];
  buildInputs = [ openssl ];
  cmakeFlags = [ "-DHADOOP_CONF_DIR=/run/wrappers/yarn-nodemanager/etc/hadoop" ];

  installPhase = ''
    mkdir $out
    mv target/usr/local/bin $out/
  '';

  sourceRoot =
    "hadoop-${finalAttrs.version}-src/hadoop-yarn-project/hadoop-yarn/"
    + "hadoop-yarn-server/hadoop-yarn-server-nodemanager/src";

  meta = {
    description = "Framework for distributed processing of large data sets across clusters of computers";

    longDescription = ''
      The Hadoop YARN Container Executor is a native component responsible for managing the lifecycle of containers
      on individual nodes in a Hadoop YARN cluster. It launches, monitors, and terminates containers, ensuring that
      resources like CPU and memory are allocated according to the policies defined in the ResourceManager.
    '';

    homepage = "https://hadoop.apache.org/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ illustris ];
    platforms = lib.filter (lib.strings.hasSuffix "linux") (lib.attrNames platformAttrs);
  };
})
