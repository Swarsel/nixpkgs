{
  lib,
  stdenv,
  fetchurl,
  coreutils,
  dpkg,
  file,
  ghostscript,
  gnugrep,
  gnused,
  makeWrapper,
  perl,
  pkgsi686Linux,
  which,
}:
let
  version = "1.0.2-0";
  model = "dcpl3550cdw";
  interpreter = "${pkgsi686Linux.stdenv.cc.libc}/lib/ld-linux.so.2";
in
stdenv.mkDerivation {
  inherit version;
  pname = "cups-brother-${model}";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103919/dcpl3550cdwpdrv-${version}.i386.deb";
    hash = "sha256-FbtqISK3f1q1+JXJ+RP5O/8G0ZW9gcCS7OI0YRljwyY=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    substituteInPlace $out/opt/brother/Printers/${model}/lpd/filter_${model} \
      --replace-fail /usr/bin/perl ${lib.getExe perl} \
      --replace-fail "PRINTER =~" "PRINTER = \"${model}\"; #" \
      --replace-fail "BR_PRT_PATH =~" "BR_PRT_PATH = \"$out/opt/brother/Printers/${model}/\"; #"

    substituteInPlace $out/opt/brother/Printers/${model}/cupswrapper/brother_lpdwrapper_${model} \
      --replace-fail /usr/bin/perl ${lib.getExe perl} \
      --replace-fail "basedir =~ " "basedir = \"$out/opt/brother/Printers/${model}/\"; #" \
      --replace-fail "PRINTER =~ " "PRINTER = \"${model}\"; #" \
      --replace-fail "LPDCONFIGEXE=" "LPDCONFIGEXE=\"$out/usr/bin/brprintconf_\"; #"

    patchelf --set-interpreter ${interpreter} $out/opt/brother/Printers/${model}/lpd/br${model}filter
    patchelf --set-interpreter ${interpreter} $out/usr/bin/brprintconf_${model}

    mkdir -p $out/lib/cups/filter $out/share/cups/model
    ln -s $out/opt/brother/Printers/${model}/lpd/filter_${model} $out/lib/cups/filter/brlpdwrapper${model}
    ln -s $out/opt/brother/Printers/${model}/cupswrapper/brother_lpdwrapper_${model} $out/lib/cups/filter/brother_lpdwrapper_${model}
    ln -s $out/opt/brother/Printers/${model}/cupswrapper/brother_${model}_printer_en.ppd $out/share/cups/model/brother_${model}_printer_en.ppd

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/opt/brother/Printers/${model}/lpd/filter_${model} \
        --prefix PATH ":" ${
          lib.makeBinPath [
            ghostscript
            file
            gnused
            gnugrep
            coreutils
            which
          ]
        }
    wrapProgram $out/opt/brother/Printers/${model}/cupswrapper/brother_lpdwrapper_${model} \
      --prefix PATH ":" ${
        lib.makeBinPath [
          gnugrep
          coreutils
        ]
      }
    wrapProgram $out/usr/bin/brprintconf_${model} \
      --set LD_PRELOAD "${pkgsi686Linux.libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS /opt=$out/opt
    wrapProgram $out/opt/brother/Printers/${model}/lpd/br${model}filter \
      --set LD_PRELOAD "${pkgsi686Linux.libredirect}/lib/libredirect.so" \
      --set NIX_REDIRECTS /opt=$out/opt
  '';

  unpackPhase = ''
    runHook preUnpack

    dpkg-deb -x $src $out

    runHook postUnpack
  '';

  meta = {
    description = "Brother DCP-L3550CDW printer driver";
    homepage = "https://www.brother.com/";

    license = with lib.licenses; [
      unfreeRedistributable
      gpl2Only
    ];

    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ Tert0 ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];

    downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=eu_ot&lang=en&prod=${model}_eu&os=128";
  };
}
