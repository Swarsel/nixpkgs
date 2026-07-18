{
  lib,
  stdenv,
  copyDesktopItems,
  coreutils,
  desktopToDarwinBundle,
  gnutar,
  makeDesktopItem,
  net-tools,
  protobuf,
  python3Packages,
  qt6,
  rcu,
  requireFile,
  runCommand,
  system-config-printer,
  testers,
  wget,
}:
python3Packages.buildPythonApplication rec {
  pname = "rcu";
  version = "5.1.0";

  src =
    let
      src-tarball = requireFile {
        hash = "sha256-s5cqUu2hJEHpLVUwTbNYLQCNXMjv0vFGzQb041+XEqA=";
        name = "rcu-${version}-source.tar.gz";
        url = "https://www.davisr.me/projects/rcu/";

        meta = {
          # `requireFile` sets `lib.licenses.unfree` by default
          inherit (meta) license;
        };
      };
    in
    runCommand "${src-tarball.name}-unpacked" { } ''
      gunzip -ck ${src-tarball} | tar -xvf-
      mv rcu $out
      ln -s ${src-tarball} $out/src
    '';

  patches = [
    ./Port-to-paramiko-4.x.patch
  ];

  postPatch = ''
    substituteInPlace src/main.py \
      --replace-fail "ui_basepath = '.'" "ui_basepath = '$out/share/rcu'"

    substituteInPlace package_support/gnulinux/50-remarkable.rules \
      --replace-fail 'GROUP="yourgroup"' 'GROUP="users"'

    # This must match the protobuf version imported at runtime, regenerate it
    rm src/model/update_metadata_pb2.py
    protoc --proto_path src/model src/model/update_metadata.proto --python_out=src/model

    # We don't make it available at this location, wrapping adds it to PATH instead
    substituteInPlace src/model/document.py \
      --replace-fail '/sbin/ifconfig' 'ifconfig'
  '';

  nativeBuildInputs = [
    copyDesktopItems
    protobuf
    qt6.wrapQtAppsHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    desktopToDarwinBundle
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
    qt6.qtsvg
  ];

  propagatedBuildInputs = with python3Packages; [
    certifi
    packaging
    paramiko
    pdfminer-six
    pikepdf
    pillow
    python3Packages.protobuf # otherwise it picks up protobuf from function args
    pyside6
  ];

  # No tests
  doCheck = false;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share}
    cp -r src $out/share/rcu

  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    install -Dm644 package_support/gnulinux/50-remarkable.rules $out/etc/udev/rules.d/50-remarkable.rules
  ''
  + ''

    # Keep source from being GC'd by linking into it

    for icondir in $(find icons -type d -name '[0-9]*x[0-9]*'); do
      iconsize=$(basename $icondir)
      mkdir -p $out/share/icons/hicolor/$iconsize/apps
      ln -s ${src}/icons/$iconsize/rcu-icon-$iconsize.png $out/share/icons/hicolor/$iconsize/apps/rcu.png
    done

    mkdir -p $out/share/icons/hicolor/scalable/apps
    ln -s ${src}/icons/64x64/rcu-icon-64x64.svg $out/share/icons/hicolor/scalable/apps/rcu.svg

    mkdir -p $out/share/doc/rcu
    for docfile in {COPYING,manual.pdf}; do
      ln -s ${src}/manual/$docfile $out/share/doc/rcu/$docfile
    done

    mkdir -p $out/share/licenses/rcu
    ln -s ${src}/COPYING $out/share/licenses/rcu/COPYING

    runHook postInstall
  '';

  preFixup = ''
    makeWrapperArgs+=(
      "''${qtWrapperArgs[@]}"
      --prefix PATH : ${
        lib.makeBinPath [
          coreutils
          gnutar
          wget
        ]
      }
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    --prefix PATH : ${
      lib.makeBinPath [
        net-tools
        system-config-printer
      ]
    }
  ''
  + ''
    )
  '';

  postFixup = ''
    makeWrapper ${lib.getExe python3Packages.python} $out/bin/rcu \
      ''${makeWrapperArgs[@]} \
      --prefix PYTHONPATH : ${
        python3Packages.makePythonPath (propagatedBuildInputs ++ [ (placeholder "out") ])
      } \
      --add-flags $out/share/rcu/main.py
  '';

  desktopItems = [
    (makeDesktopItem {
      comment = "All-in-one offline/local management software for reMarkable e-paper tablets";
      desktopName = "reMarkable Connection Utility";
      exec = "rcu";
      icon = "rcu";
      name = "rcu";
    })
  ];

  dontBuild = true;
  dontConfigure = true;
  # Manually creating wrapper, hook struggles with lack of shebang & symlink
  dontWrapPythonPrograms = true;
  pyproject = false;

  passthru = {
    tests.version = testers.testVersion {
      package = rcu;
    };

    # Python stuff automatically adds an updateScript that just fails
    updateScript = null;
  };

  meta = {
    description = "All-in-one offline/local management software for reMarkable e-paper tablets";
    homepage = "http://www.davisr.me/projects/rcu/";
    license = lib.licenses.agpl3Plus;

    maintainers = with lib.maintainers; [
      m0streng0
    ];

    mainProgram = "rcu";
    hydraPlatforms = [ ]; # requireFile used as src
  };
}
