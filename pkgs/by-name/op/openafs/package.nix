{
  lib,
  stdenv,
  fetchurl,
  autoconf,
  automake,
  bison,
  buildPackages,
  callPackage,
  dblatex, # Extra developer documentation
  docbook_xml_dtd_43,
  docbook_xsl,
  doxygen,
  flex,
  glibc,
  libkrb5,
  libtool_2,
  libxslt,
  ncurses, # Extra ncurses utilities. Needed for debugging and monitoring.
  perl,
  tsm-client, # Tivoli Storage Manager Backup Client from IBM
  which,
  withDevdoc ? false,
  withNcurses ? false,
  withTsm ? false,
}:

with (import ./srcs.nix { inherit fetchurl; });

stdenv.mkDerivation {
  inherit version srcs;
  pname = "openafs";

  outputs = [
    "out"
    "dev"
    "man"
    "doc"
  ]
  ++ lib.optional withDevdoc "devdoc";

  patches = [
    ./bosserver.patch
    ./cross-build.patch
  ]
  ++ lib.optional withTsm ./tsmbac.patch;

  nativeBuildInputs = [
    autoconf
    automake
    flex
    libxslt
    libtool_2
    perl
    which
    bison
  ]
  ++ lib.optionals withDevdoc [
    doxygen
    dblatex
  ];

  buildInputs = [ libkrb5 ] ++ lib.optional withNcurses ncurses;
  buildFlags = [ "all_nolibafs" ];

  preConfigure = ''
    patchShebangs .
    for i in `grep -l -R '/usr/\(include\|src\)' .`; do
      echo "Patch /usr/include and /usr/src in $i"
      substituteInPlace $i \
        --replace "/usr/include" "${glibc.dev}/include" \
        --replace "/usr/src" "$TMP"
    done

    for i in ./doc/xml/{AdminGuide,QuickStartUnix,UserGuide}/*.xml; do
      substituteInPlace "''${i}" --replace "http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd" \
        "${docbook_xml_dtd_43}/xml/dtd/docbook/docbookx.dtd"
    done

    ./regen.sh


    configureFlagsArray=(
      "--with-krb5"
      "--sysconfdir=/etc"
      "--localstatedir=/var"
      "--disable-kernel-module"
      "--disable-fuse-client"
      "--with-docbook-stylesheets=${docbook_xsl}/share/xml/docbook-xsl"
      ${lib.optionalString withTsm "--enable-tivoli-tsm"}
      ${lib.optionalString (!withNcurses) "--disable-gtx"}
      "--disable-linux-d_splice-alias-extra-iput"
    )
  ''
  + lib.optionalString withTsm ''
    export XBSA_CFLAGS="-Dxbsa -DNEW_XBSA -I${tsm-client}/opt/tivoli/tsm/client/api/bin64/sample -DXBSA_TSMLIB=\\\"${tsm-client}/lib64/libApiTSM64.so\\\""
  '';

  postBuild = ''
    for d in doc/xml/{AdminGuide,QuickStartUnix,UserGuide}; do
      make -C "''${d}" index.html
    done
  ''
  + lib.optionalString withDevdoc ''
    make dox
  '';

  postInstall = ''
    mkdir -p $doc/share/doc/openafs/{AdminGuide,QuickStartUnix,UserGuide}
    cp -r doc/txt README LICENSE $doc/share/doc/openafs
    for d in AdminGuide QuickStartUnix UserGuide ; do
      cp "doc/xml/''${d}"/*.html "$doc/share/doc/openafs/''${d}"
    done

    cp src/tools/dumpscan/{afsdump_dirlist,afsdump_extract,afsdump_scan,dumptool} $out/bin

    rm -r $out/lib/openafs
  ''
  + lib.optionalString withDevdoc ''
    mkdir -p $devdoc/share/devhelp/openafs/doxygen
    cp -r doc/{pdf,protocol} $devdoc/share/devhelp/openafs
    cp -r doc/doxygen/output/html $devdoc/share/devhelp/openafs/doxygen
  '';

  # remove forbidden references to $TMPDIR
  preFixup = ''
    for f in "$out"/bin/*; do
      if isELF "$f"; then
        patchelf --shrink-rpath --allowed-rpath-prefixes "$NIX_STORE" "$f"
      fi
    done
  '';

  depsBuildBuild = [ buildPackages.stdenv.cc ];
  # Makefiles don't include install targets for all new shared libs, yet.
  dontDisableStatic = true;
  enableParallelBuilding = false;
  setOutputFlags = false;
  passthru.cellservdb = callPackage ./cellservdb.nix { };

  meta = {
    description = "Open AFS client";
    homepage = "https://www.openafs.org";
    license = lib.licenses.ipl10;

    maintainers = [
      lib.maintainers.spacefrogg
    ];

    platforms = lib.platforms.linux;

    outputsToInstall = [
      "out"
      "doc"
      "man"
    ];
  };
}
