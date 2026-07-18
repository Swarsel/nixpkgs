{
  lib,
  stdenv,
  fetchurl,
  config,
  fetchzip,
  unzip,
}:

rec {

  acejump = buildEclipsePlugin rec {
    pname = "acejump";
    version = "1.0.0.201610261941";

    srcFeature = fetchurl {
      sha256 = "1szswjxp9g70ibfbv3p8dlq1bngq7nc22kp657z9i9kp8309md2d";
      url = "https://tobiasmelcher.github.io/acejumpeclipse/features/acejump.feature_${version}.jar";
    };

    srcPlugin = fetchurl {
      sha256 = "1cn64xj2bm69vnn9db2xxh6kq148v83w5nx3183mrqb59ym3v9kf";
      url = "https://tobiasmelcher.github.io/acejumpeclipse/plugins/acejump_${version}.jar";
    };

    meta = {
      description = "Provides fast jumps to text based on initial letter";
      homepage = "https://github.com/tobiasmelcher/EclipseAceJump";
      license = lib.licenses.mit;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  ansi-econsole = buildEclipsePlugin rec {
    pname = "ansi-econsole";
    version = "1.3.5.201612301822";

    srcFeature = fetchurl {
      hash = "sha256-o9hnMuZeohU+AKS+ueU8dWS9HomrnqaKpWYMG5vMeJs=";
      url = "https://raw.githubusercontent.com/mihnita/ansi-econsole/8dcf0a2531cbf091310c0e01db1a1310557fc383/AnsiConSitePublished/features/net.mihai-nita.ansicon_${version}.jar";
    };

    srcPlugin = fetchurl {
      hash = "sha256-WK7WxNZHvmMHGycC/12sIKj4wKIhWT8x1Anp3zuggsg=";
      url = "https://raw.githubusercontent.com/mihnita/ansi-econsole/8dcf0a2531cbf091310c0e01db1a1310557fc383/AnsiConSitePublished/plugins/net.mihai-nita.ansicon.plugin_${version}.jar";
    };

    meta = {
      description = "Adds support for ANSI escape sequences in the Eclipse console";
      homepage = "https://mihai-nita.net/java/#ePluginAEC";
      license = lib.licenses.asl20;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  antlr-runtime_4_5 = buildEclipsePluginBase rec {
    pname = "antlr-runtime";
    version = "4.5.3";

    src = fetchurl {
      url = "https://www.antlr.org/download/${pname}-${version}.jar";
      sha256 = "0lm78i2annlczlc2cg5xvby0g1dyl0sh1y5xc2pymjlmr67a1g4k";
    };

    buildCommand = ''
      dropinDir="$out/eclipse/dropins/"
      mkdir -p $dropinDir
      cp -v $src $dropinDir/${pname}-${version}.jar
    '';

    meta = {
      description = "Powerful parser generator for processing structured text or binary files";
      homepage = "https://www.antlr.org/";
      license = lib.licenses.bsd3;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  antlr-runtime_4_7 = buildEclipsePluginBase rec {
    pname = "antlr-runtime";
    version = "4.7.1";

    src = fetchurl {
      url = "https://www.antlr.org/download/${pname}-${version}.jar";
      sha256 = "07f91mjclacrvkl8a307w2abq5wcqp0gcsnh0jg90ddfpqcnsla3";
    };

    buildCommand = ''
      dropinDir="$out/eclipse/dropins/"
      mkdir -p $dropinDir
      cp -v $src $dropinDir/${pname}-${version}.jar
    '';

    meta = {
      description = "Powerful parser generator for processing structured text or binary files";
      homepage = "https://www.antlr.org/";
      license = lib.licenses.bsd3;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  anyedittools = buildEclipsePlugin rec {
    pname = "anyedit";
    version = "2.7.3.202502241151";

    srcFeature = fetchurl {
      hash = "sha256-liEw+H8yTCrYQMe3gVQhJuxPXlSpEs4QwB2yv8n/CiE=";
      url = "https://raw.githubusercontent.com/iloveeclipse/plugins/f0560d1c628e0dba776831b1dea98d929515ebe5/features/AnyEditTools_${version}.jar";
    };

    srcPlugin = fetchurl {
      hash = "sha256-LrWCWJWZxsnMiBnTwXdWaXUoyXMYpLqXMUkHEOna2kk=";
      url = "https://raw.githubusercontent.com/iloveeclipse/plugins/f0560d1c628e0dba776831b1dea98d929515ebe5/plugins/de.loskutov.anyedit.AnyEditTools_${version}.jar";
    };

    meta = {
      description = "Adds new tools to the context menu of text-based editors";
      homepage = "https://github.com/iloveeclipse/plugins";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  autodetect-encoding = buildEclipsePlugin rec {
    pname = "autodetect-encoding";
    version = "1.8.5.201801191359";

    srcFeature = fetchurl {
      sha256 = "1m8ypsc1dwz0y6yhjgxsdi9813d38jllv7javgwvcd30g042a3kx";
      url = "https://github.com/cypher256/eclipse-encoding-plugin/raw/master/eclipse.encoding.updatesite.snapshot/features/eclipse.encoding.plugin.feature_${version}.jar";
    };

    srcPlugin = fetchurl {
      sha256 = "1n2rzybfcwp3ss2qi0fhd8vm38vdwav8j837lqiqlfcnvzwsk86m";
      url = "https://github.com/cypher256/eclipse-encoding-plugin/raw/master/eclipse.encoding.updatesite.snapshot/plugins/mergedoc.encoding_${version}.jar";
    };

    meta = {
      description = "Show file encoding and line ending for the active editor in the eclipse status bar";
      homepage = "https://github.com/cypher256/eclipse-encoding-plugin";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  # Helper for the common case where we have separate feature and
  # plugin JARs.
  buildEclipsePlugin =
    {
      srcFeature,
      name ? "eclipse-plugin-${attrs.pname}-${attrs.version}",
      srcPlugin ? null,
      srcPlugins ? [ ],
      ...
    }@attrs:
    assert srcPlugin == null -> srcPlugins != [ ];
    assert srcPlugin != null -> srcPlugins == [ ];

    let

      pSrcs = if (srcPlugin != null) then [ srcPlugin ] else srcPlugins;

    in

    buildEclipsePluginBase (
      attrs
      // {
        buildCommand = ''
          dropinDir="$out/eclipse/dropins/${name}"

          mkdir -p $dropinDir/features
          unzip ${srcFeature} -d $dropinDir/features/

          mkdir -p $dropinDir/plugins
          for plugin in ${toString pSrcs}; do
            cp -v $plugin $dropinDir/plugins/$(stripHash $plugin)
          done
        '';

        srcs = [ srcFeature ] ++ pSrcs;
      }
    );

  # A primitive builder of Eclipse plugins. This function is intended
  # to be used when building more advanced builders.
  buildEclipsePluginBase =
    {
      buildInputs ? [ ],
      name ? "eclipse-plugin-${attrs.pname}-${attrs.version}",
      passthru ? { },
      ...
    }@attrs:
    stdenv.mkDerivation (
      attrs
      // {
        inherit name;
        buildInputs = buildInputs ++ [ unzip ];

        passthru = {
          isEclipsePlugin = true;
        }
        // passthru;
      }
    );

  # Helper for the case where the build directory has the layout of an
  # Eclipse update site, that is, it contains the directories
  # `features` and `plugins`. All features and plugins inside these
  # directories will be installed.
  buildEclipseUpdateSite =
    {
      name ? "eclipse-plugin-${attrs.pname}-${attrs.version}",
      ...
    }@attrs:
    buildEclipsePluginBase (
      attrs
      // {
        doCheck = false;

        installPhase = ''
          dropinDir="$out/eclipse/dropins/${name}"

          # Install features.
          cd features
          for feature in *.jar; do
            featureName=''${feature%.jar}
            mkdir -p $dropinDir/features/$featureName
            unzip $feature -d $dropinDir/features/$featureName
          done
          cd ..

          # Install plugins.
          mkdir -p $dropinDir/plugins

          # A bundle should be unpacked if the manifest matches this
          # pattern.
          unpackPat="Eclipse-BundleShape:\\s*dir"

          cd plugins
          for plugin in *.jar ; do
            pluginName=''${plugin%.jar}
            manifest=$(unzip -p $plugin META-INF/MANIFEST.MF)

            if [[ $manifest =~ $unpackPat ]] ; then
              mkdir $dropinDir/plugins/$pluginName
              unzip $plugin -d $dropinDir/plugins/$pluginName
            else
              cp -v $plugin $dropinDir/plugins/
            fi
          done
          cd ..
        '';

        dontBuild = true;
      }
    );

  cdt = buildEclipseUpdateSite rec {
    pname = "cdt";
    # find current version at https://github.com/eclipse-cdt/cdt/releases
    version = "11.4.0";

    src = fetchzip {
      url = "https://www.eclipse.org/downloads/download.php?r=1&nf=1&file=/tools/cdt/releases/${lib.versions.majorMinor version}/${pname}-${version}/${pname}-${version}.zip";
      hash = "sha256-39AoB5cKRQMFpRaOlrTEsyEKZYVqdTp1tMtlaDjjZ84=";
      stripRoot = false;
    };

    meta = {
      description = "C/C++ development tooling";
      homepage = "https://eclipse.org/cdt/";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      maintainers = [ lib.maintainers.bjornfor ];
      platforms = lib.platforms.all;
    };
  };

  checkstyle = buildEclipseUpdateSite rec {
    pname = "checkstyle";
    version = "8.7.0.201801131309";

    src = fetchzip {
      url = "mirror://sourceforge/project/eclipse-cs/Eclipse%20Checkstyle%20Plug-in/8.7.0/net.sf.eclipsecs-updatesite_${version}.zip";
      sha256 = "07fymk705x4mwq7vh2i6frsf67jql4bzrkdzhb4n74zb0g1dib60";
      stripRoot = false;
    };

    meta = {
      description = "Checkstyle integration into the Eclipse IDE";
      homepage = "https://eclipse-cs.sourceforge.net/";
      license = lib.licenses.lgpl21;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };

  };

  color-theme = buildEclipsePlugin rec {
    pname = "color-theme";
    version = "1.0.0.201410260308";

    srcFeature = fetchurl {
      sha256 = "128b9b1cib5ff0w1114ns5mrbrhj2kcm358l4dpnma1s8gklm8g2";
      url = "https://eclipse-color-theme.github.io/update/features/com.github.eclipsecolortheme.feature_${version}.jar";
    };

    srcPlugin = fetchurl {
      sha256 = "0wz61909bhqwzpqwll27ia0cn3anyp81haqx3rj1iq42cbl42h0y";
      url = "https://eclipse-color-theme.github.io/update/plugins/com.github.eclipsecolortheme_${version}.jar";
    };

    meta = {
      description = "Plugin to switch color themes conveniently and without side effects";
      homepage = "http://eclipsecolorthemes.org/";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  cup = buildEclipsePlugin rec {
    pname = "cup";
    version = "1.1.0.201604221613";
    propagatedBuildInputs = [ zest ];

    srcFeature = fetchurl {
      sha256 = "13nnsf0cqg02z3af6xg45rhcgiffsibxbx6h1zahjv7igvqgkyna";
      url = "http://www2.in.tum.de/projects/cup/eclipse/features/CupEclipsePluginFeature_${version}.jar";
    };

    srcPlugins = [
      (fetchurl {
        sha256 = "0kif8kivrysprva1pxzajm88gi967qf7idhb6ga2xpvsdcris91j";
        url = "http://www2.in.tum.de/projects/cup/eclipse/plugins/CupReferencedLibraries_${version_}.jar";
      })

      (fetchurl {
        sha256 = "022phbrsny3gb8npb6sxyqqxacx138q5bd7dq3gqxh3kprx5chbl";
        url = "http://www2.in.tum.de/projects/cup/eclipse/plugins/de.tum.in.www2.CupPlugin_${version}.jar";
      })
    ];

    version_ = "1.0.0.201604221613";

    meta = {
      description = "IDE for developing CUP based parsers";
      homepage = "http://www2.cs.tum.edu/projects/cup/eclipse.php";
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      maintainers = [ lib.maintainers.romildo ];
      platforms = lib.platforms.all;
    };
  };

  drools = buildEclipseUpdateSite rec {
    pname = "drools";
    version = "7.17.0.Final";

    src = fetchzip {
      url = "https://download.jboss.org/drools/release/${version}/droolsjbpm-tools-distribution-${version}.zip";
      hash = "sha512-dWTS72R2VRgGnG6JafMwZ+wd+1e13pil0SAz2HDMXUmtgYa9iLLtma3SjcDJeWdOoblzWHRu7Ihblx3+Ogb2sQ==";

      postFetch = ''
        # update site is a couple levels deep, alongside some other irrelevant stuff
        cd $out;
        find . -type f -not -path ./binaries/org.drools.updatesite/\* -exec rm {} \;
        rmdir sources;
        mv binaries/org.drools.updatesite/* .;
        rmdir binaries/org.drools.updatesite binaries;
      '';
    };

    meta = {
      description = "Drools is a Business Rules Management System (BRMS) solution";
      homepage = "https://www.drools.org/";
      license = lib.licenses.asl20;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    };
  };

  eclemma = buildEclipseUpdateSite {
    pname = "eclemma";
    version = "2.3.2.201409141915";

    src = fetchzip {
      url = "mirror://sourceforge/project/eclemma/01_EclEmma_Releases/2.3.2/eclemma-2.3.2.zip";
      sha256 = "0w1kwcjh45p7msv5vpc8i6dsqwrnfmjama6vavpnxlji56jd3c43";
      stripRoot = false;
    };

    meta = {
      description = "EclEmma is a free Java code coverage tool for Eclipse";
      homepage = "https://www.eclemma.org/";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  embed-cdt = buildEclipseUpdateSite rec {
    pname = "embed-cdt";
    version = "6.3.1";

    src = fetchzip {
      url = "https://github.com/eclipse-embed-cdt/eclipse-plugins/archive/v${version}.zip";
      sha256 = "sha256-0wHRIls48NGDQzD+wuX79Thgiax+VVYVPJw2Z6NEzsg=";
      stripRoot = true;
    };

    meta = {
      description = "Embedded C/C++ Development Tools (formerly GNU MCU/ARM Eclipse)";
      homepage = "https://github.com/eclipse-embed-cdt/eclipse-plugins";
      license = lib.licenses.epl20;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      maintainers = [ lib.maintainers.bjornfor ];
      platforms = lib.platforms.all;
    };
  };

  findbugs = buildEclipsePlugin rec {
    pname = "findbugs";
    version = "3.0.1.20150306-5afe4d1";

    srcFeature = fetchurl {
      sha256 = "1m9fav2xlb9wrx2d00lpnh2sy0w5yzawynxm6xhhbfdzd0vpfr9v";
      url = "http://findbugs.cs.umd.edu/eclipse/features/edu.umd.cs.findbugs.plugin.eclipse_${version}.jar";
    };

    srcPlugin = fetchurl {
      sha256 = "10p3mrbp9wi6jhlmmc23qv7frh605a23pqsc7w96569bsfb5wa8q";
      url = "http://findbugs.cs.umd.edu/eclipse/plugins/edu.umd.cs.findbugs.plugin.eclipse_${version}.jar";
    };

    meta = {
      description = "Plugin that uses static analysis to look for bugs in Java code";
      homepage = "http://findbugs.sourceforge.net/";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  freemarker = buildEclipseUpdateSite rec {
    pname = "freemarker";
    version = "1.5.305";

    src = fetchzip {
      url = "https://github.com/ddekany/jbosstools-freemarker/releases/download/v${version}/freemarker.site-${version}.zip";
      sha256 = "1qrhi300vk07gi14r445wvy0bvghbjd6c4k7q09pqpaxv6raiczn";
      stripRoot = false;
    };

    meta = {
      description = "Plugin that provides an editor for Apache FreeMarker files";
      homepage = "https://github.com/ddekany/jbosstools-freemarker";
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    };
  };

  gnuarmeclipse = embed-cdt; # backward compat alias, added 2022-11-04

  jdt-codemining = buildEclipsePlugin rec {
    pname = "jdt-codemining";
    version = "1.0.0.201806221018";

    srcFeature = fetchurl {
      sha256 = "1vy30rsb9xifn4r1r2n84d48g6riadzli1xvhfs1mf5pkm5ljwl6";
      url = "http://oss.opensagres.fr/jdt-codemining/snapshot/features/jdt-codemining-feature_${version}.jar";
    };

    srcPlugin = fetchurl {
      sha256 = "0qdzlqcjcm2i4mwhmcdml0am83z1dayrcmf37ji7vmw6iwdk1xmp";
      url = "http://oss.opensagres.fr/jdt-codemining/snapshot/plugins/org.eclipse.jdt.codemining_${version}.jar";
    };

    meta = {
      description = "Provides JDT Java CodeMining";
      homepage = "https://github.com/angelozerr/jdt-codemining";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  jsonedit = buildEclipsePlugin rec {
    pname = "jsonedit";
    version = "1.1.1";
    propagatedBuildInputs = [ antlr-runtime_4_7 ];

    srcFeature = fetchurl {
      sha256 = "0zkg8d8x3l5jpfxi0mz9dn62wmy4fjgpwdikj280fvsklmcw5b86";
      url = "https://boothen.github.io/Json-Eclipse-Plugin/features/jsonedit-feature_${version}.jar";
    };

    srcPlugins =
      let
        fetch =
          { h, n }:
          fetchurl {
            sha256 = h;
            url = "https://boothen.github.io/Json-Eclipse-Plugin/plugins/jsonedit-${n}_${version}.jar";
          };
      in
      map fetch [
        {
          h = "0svs0aswnhl26cqw6bmw30cisx4cr50kc5njg272sy5c1dqjm1zq";
          n = "core";
        }
        {
          h = "1q62dinrbb18aywbvii4mlr7rxa20rdsxxd6grix9y8h9776q4l5";
          n = "editor";
        }
        {
          h = "1qh4ijfb1gl9xza5ydi87v1kyima3a9sh7lncwdy1way3pdhln1y";
          n = "folding";
        }
        {
          h = "1pr6k2pdfdwx8jqs7gx7wzn3gxsql3sk6lnjha8m15lv4al6d4kj";
          n = "model";
        }
        {
          h = "1jgr2g16j3id8v367jbgd6kx6g2w636fbzmd8jvkvkh7y1jgjqxm";
          n = "outline";
        }
        {
          h = "027fhaqa5xbil6dmhvkbpha3pgw6dpmc2im3nlliyds57mdmdb1h";
          n = "preferences";
        }
        {
          h = "0clywylyidrxlqs0n816nhgjmk1c3xl7sn904ki4q050amfy0wb2";
          n = "text";
        }
      ];

    meta = {
      description = "Adds support for JSON files to Eclipse";
      homepage = "https://github.com/boothen/Json-Eclipse-Plugin";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  rustdt = buildEclipseUpdateSite rec {
    pname = "rustdt";
    version = "0.6.2";

    src = fetchzip {
      url = "https://github.com/${owner}/${repo}/archive/${rev}.zip";
      sha256 = "1xfj4j27d1h4bdf2v7f78zi8lz4zkkj7s9kskmsqx5jcs2d459yp";

      postFetch = ''
        mv "$out/${repo}-${rev}/releases/local-repo/"* "$out/"
      '';

      stripRoot = false;
    };

    owner = "RustDT";
    repo = "rustdt.github.io";
    rev = "5cbe753008c40555c493092a6f4ae1ffbff0b3ce";

    meta = {
      description = "Rust development tooling";
      homepage = "https://github.com/RustDT";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  spotbugs = buildEclipseUpdateSite rec {
    pname = "spotbugs";
    version = "3.1.11";

    src = fetchzip {
      url = "https://github.com/spotbugs/spotbugs/releases/download/${version}/eclipsePlugin.zip";
      sha256 = "0aanqwx3gy1arpbkqd846381hiy6272lzwhfjl94x8jhfykpqqbj";
      stripRoot = false;
    };

    meta = {
      description = "Plugin that uses static analysis to look for bugs in Java code";
      homepage = "https://spotbugs.github.io/";
      license = lib.licenses.lgpl21;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  testng = buildEclipsePlugin rec {
    pname = "testng";
    version = "6.9.13.201609291640";

    srcFeature = fetchurl {
      hash = "sha256-JahgneGUJN4jVxgXdkhhj5/TENXKXG635UO9Q7Vnnws=";
      url = "https://raw.githubusercontent.com/testng-team/testng-eclipse-update-site/0eb404d0c65dc0ef25b19145bb44a56326a53da6/updatesites/${version}/features/org.testng.eclipse_${version}.jar";
    };

    srcPlugin = fetchurl {
      hash = "sha256-DTE60G+1ZnBT0i6FHuYDQlzwxhwAeXbHN3hgkYbhn8g=";
      url = "https://raw.githubusercontent.com/testng-team/testng-eclipse-update-site/0eb404d0c65dc0ef25b19145bb44a56326a53da6/updatesites/${version}/plugins/org.testng.eclipse_${version}.jar";
    };

    meta = {
      description = "Eclipse plugin for the TestNG testing framework";
      homepage = "https://testng.org/doc/";
      license = lib.licenses.asl20;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  vrapper = buildEclipseUpdateSite rec {
    pname = "vrapper";
    version = "0.72.0";

    src = fetchzip {
      url = "https://github.com/${owner}/${repo}/releases/download/${version}/vrapper_${version}_${date}.zip";
      sha256 = "0nyirf6km97q211cxfy01kidxac20m8ba3kk9xj73ykrhsk3cxjp";
      stripRoot = false;
    };

    date = "20170311";
    owner = "vrapper";
    repo = "vrapper";

    meta = {
      description = "Wrapper to provide a Vim-like input scheme for moving around and editing text";
      homepage = "https://github.com/vrapper/vrapper";
      license = lib.licenses.gpl3;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      maintainers = [ lib.maintainers.stumoss ];
      platforms = lib.platforms.all;
    };
  };

  yedit = buildEclipsePlugin rec {
    pname = "yedit";
    version = "1.0.20.201509041456";

    srcFeature = fetchurl {
      sha256 = "0rps73y19gwlrdr8jjrg3rhcaaagghnmri8297inxc5q2dvg0mlk";
      url = "http://dadacoalition.org/yedit/features/org.dadacoalition.yedit.feature_${version}-RELEASE.jar";
    };

    srcPlugin = fetchurl {
      sha256 = "1wpyw4z28ka60z36f8m71kz1giajcm26wb9bpv18sjiqwdgx9v0z";
      url = "http://dadacoalition.org/yedit/plugins/org.dadacoalition.yedit_${version}-RELEASE.jar";
    };

    meta = {
      description = "YAML editor plugin for Eclipse";
      homepage = "https://github.com/oyse/yedit";
      license = lib.licenses.epl10;
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      platforms = lib.platforms.all;
    };
  };

  zest = buildEclipseUpdateSite rec {
    pname = "zest";
    version = "3.9.101";

    src = fetchurl {
      url = "http://archive.eclipse.org/tools/gef/downloads/drops/${version}/R201408150207/GEF-${pname}-${version}.zip";
      sha256 = "01scn7cmcrjcp387spjm8ifgwrwwi77ypildandbisfvhj3qqs7m";
    };

    meta = {
      description = "Eclipse Visualization Toolkit";
      homepage = "https://www.eclipse.org/gef/zest/";
      sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
      maintainers = [ lib.maintainers.romildo ];
      platforms = lib.platforms.all;
    };
  };
}
// lib.optionalAttrs config.allowAliases {
  # Added 2025-11-16
  bytecode-outline = throw "eclipses.plugins.bytecode-outline has been removed due to being removed upstream.";
  ivy = throw "eclipses.plugins.ivy has been removed due to being archived upstream.";
  ivyant = throw "eclipses.plugins.ivyant has been removed due to being archived upstream.";
  ivyde = throw "eclipses.plugins.ivyde has been removed due to being archived upstream.";
  ivyderv = throw "eclipses.plugins.inyderv has been removed due to being archived upstream.";
  scala = throw "eclipses.plugins.scala has been removed due to being deprecated upstream.";
}
