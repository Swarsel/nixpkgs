# Before adding a new extension, read ./README.md

{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  callPackage,
  config,
  jdk,
  jq,
  llvmPackages,
  moreutils,
  protobuf,
  python3Packages,
  vscode-utils,
  zlib,
}:

let
  inherit (vscode-utils) buildVscodeMarketplaceExtension;

  baseExtensions =
    self:
    lib.mapAttrs (_n: lib.recurseIntoAttrs) {
      "13xforever".language-x86-64-assembly = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.1.5";
          hash = "sha256-WIhmAZLR2WOSqQF3ozJ/Vr3Rp6HdSK7L23T3h4AVaGM=";
          name = "language-x86-64-assembly";
          publisher = "13xforever";
        };

        meta = {
          description = "Cutting edge x86 and x86_64 assembly syntax highlighting";
          homepage = "https://github.com/13xforever/x86_64-assembly-vscode";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=13xforever.language-x86-64-assembly";
        };
      };

      "1Password".op-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.5";
          hash = "sha256-J7vAK2t6fSjm5i6y3+88aO84ipFwekQkJMD7W3EIWrc=";
          name = "op-vscode";
          publisher = "1Password";
        };

        meta = {
          description = "VSCode extension that integrates your development workflow with 1Password service";
          homepage = "https://github.com/1Password/op-vscode";
          changelog = "https://github.com/1Password/op-vscode/releases";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers._2gn ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=1Password.op-vscode";
        };
      };

      "2gua".rainbow-brackets = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.6";
          name = "rainbow-brackets";
          publisher = "2gua";
          sha256 = "TVBvF/5KQVvWX1uHwZDlmvwGjOO5/lXbgVzB26U8rNQ=";
        };

        meta = {
          description = "Visual Studio Code extension providing rainbow brackets";
          homepage = "https://github.com/lcultx/rainbow-brackets";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.CompEng0001 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=2gua.rainbow-brackets";
        };
      };

      "42crunch".vscode-openapi = buildVscodeMarketplaceExtension rec {
        mktplcRef = {
          version = "4.40.0";
          hash = "sha256-nV7RZpDd+15YmINKrFSIlFurC955bnE4A8esrKWYVnE=";
          name = "vscode-openapi";
          publisher = "42Crunch";
        };

        meta = {
          description = "Visual Studio Code extension with rich support for the OpenAPI Specification (OAS)";
          homepage = "https://github.com/42Crunch/vscode-openapi";
          changelog = "https://github.com/42Crunch/vscode-openapi/blob/v${mktplcRef.version}/CHANGELOG.md";
          license = lib.licenses.agpl3Only;
          maintainers = [ lib.maintainers.benhiemer ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=42Crunch.vscode-openapi";
        };
      };

      "4ops".terraform = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.5";
          hash = "sha256-y5LljxK8V9Fir9EoG8g9N735gISrlMg3czN21qF/KjI=";
          name = "terraform";
          publisher = "4ops";
        };

        meta = {
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.kamadorueda ];
        };
      };

      ExiaHuang.dictionary = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.2";
          hash = "sha256-caNcbDTB/F2mdlGpfIfJv13lzY5Wwj7p7r8dAte9+3A=";
          name = "dictionary";
          publisher = "ExiaHuang";
        };

        meta = {
          description = "Visual Studio Code extension of using chinese-english dictonary in right-click menu";
          homepage = "https://github.com/exiahuang/fanyi-vscode";
          changelog = "https://marketplace.visualstudio.com/items/ExiaHuang.dictionary/changelog";
          license = lib.licenses.gpl3Only;
          maintainers = with lib.maintainers; [ onedragon ];
        };
      };

      Google.gemini-cli-vscode-ide-companion = callPackage ./Google.gemini-cli-vscode-ide-companion { };

      RoweWilsonFrederiskHolme.wikitext = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "4.0.5";
          hash = "sha256-VyrcgS93B5Xd4s101lnTw9o27ffcvmxkShCKJ+6H+2w=";
          name = "wikitext";
          publisher = "RoweWilsonFrederiskHolme";
        };

        meta = {
          description = "Extension that helps users view and write MediaWiki's Wikitext files";

          longDescription = ''
            With this extension, you can more easily discover your grammatical problems
            through the marked and styled text. The plugin is based on MediaWiki's
            Wikitext standard, but the rules are somewhat stricter, which helps users
            write text that is easier to read and maintain.
          '';

          homepage = "https://github.com/Frederisk/Wikitext-VSCode-Extension";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.rapiteanu ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=RoweWilsonFrederiskHolme.wikitext";
        };
      };

      a5huynh.vscode-ron = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.11.0";
          hash = "sha256-xIGOgK/kcdwm8EicAGIac5zPqRxw6ZTRLwteC03NKQ8=";
          name = "vscode-ron";
          publisher = "a5huynh";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      aaron-bond.better-comments = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.0.2";
          name = "better-comments";
          publisher = "aaron-bond";
          sha256 = "850980f0f5a37f635deb4bf9100baaa83f0b204bbbb25acdb3c96e73778f8197";
        };

        meta = {
          description = "Improve your code commenting by annotating with alert, informational, TODOs, and more";
          homepage = "https://github.com/aaron-bond/better-comments";
          changelog = "https://marketplace.visualstudio.com/items/aaron-bond.better-comments/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.DataHearth ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=aaron-bond.better-comments";
        };
      };

      adpyke.codesnap = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.3.4";
          hash = "sha256-dR6qODSTK377OJpmUqG9R85l1sf9fvJJACjrYhSRWgQ=";
          name = "codesnap";
          publisher = "adpyke";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      adzero.vscode-sievehighlight = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.8";
          hash = "sha256-bogT5Cshl6Rab5iiXWPwju29XX4PHdbR64J5UFPSlRo=";
          name = "vscode-sievehighlight";
          publisher = "adzero";
        };

        meta = {
          description = "Visual Studio Code extension to enable syntax highlight support for Sieve mail filtering language";
          homepage = "https://github.com/adzero/vscode-sievehighlight";
          changelog = "https://marketplace.visualstudio.com/items/adzero.vscode-sievehighlight/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=adzero.vscode-sievehighlight";
        };
      };

      alanz.vscode-hie-server = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.1"; # see the note above
          name = "vscode-hie-server";
          publisher = "alanz";
          sha256 = "sha256-/RA+7OnoR5Nu2bK6dFEL8aZW+CJkTeM0bKG6k5X1g+I=";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      albymor.increment-selection = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.0";
          hash = "sha256-iP4c0xLPiTsgD8Q8Kq9jP54HpdnBveKRY31Ro97ROJ8=";
          name = "increment-selection";
          publisher = "albymor";
        };

        meta = {
          description = "Increment, decrement or reverse selection with multiple cursors";
          homepage = "https://github.com/albymor/Increment-Selection";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=albymor.increment-selection";
        };
      };

      alefragnani.bookmarks = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "14.1.1";
          hash = "sha256-oy0SRapLmr8wQhYtmCcE6wkMZUXgvSsje45tEdufw5M=";
          name = "bookmarks";
          publisher = "alefragnani";
        };

        meta = {
          license = lib.licenses.gpl3;
        };
      };

      alefragnani.project-manager = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "13.1.0";
          hash = "sha256-6lSEMDI8yagYxuB2Lkjf9nndJ6sGIofn/XL1vghinJM=";
          name = "project-manager";
          publisher = "alefragnani";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      alexdima.copy-relative-path = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.2";
          name = "copy-relative-path";
          publisher = "alexdima";
          sha256 = "06g601n9d6wyyiz659w60phgm011gn9jj5fy0gf5wpi2bljk3vcn";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      alexisvt.flutter-snippets = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.0.0";
          name = "flutter-snippets";
          publisher = "alexisvt";
          sha256 = "44ac46f826625f0a4aec40f2542f32c161e672ff96f45a548d0bccd9feed04ef";
        };

        meta = {
          description = "Set of helpful widget snippets for day to day Flutter development";
          homepage = "https://github.com/Alexisvt/flutter-snippets";
          changelog = "https://marketplace.visualstudio.com/items/alexisvt.flutter-snippets/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.DataHearth ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=alexisvt.flutter-snippets";
        };
      };

      almenon.arepl = callPackage ./almenon.arepl { };

      alygin.vscode-tlaplus = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.5.4";
          name = "vscode-tlaplus";
          publisher = "alygin";
          sha256 = "0mf98244z6wzb0vj6qdm3idgr2sr5086x7ss2khaxlrziif395dx";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      amazonwebservices.amazon-q-vscode = callPackage ./amazonwebservices.amazon-q-vscode { };

      angular.ng-template = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "22.0.0";
          hash = "sha256-3b77hepFW03I2hwsVvCA3f1Jqwnq5WfGAq2yqBDIt5Q=";
          name = "ng-template";
          publisher = "Angular";
        };

        meta = {
          description = "Editor services for Angular templates";
          homepage = "https://github.com/angular/vscode-ng-language-service";
          changelog = "https://marketplace.visualstudio.com/items/Angular.ng-template/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.ratsclub ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Angular.ng-template";
        };
      };

      antfu.icons-carbon = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.9";
          hash = "sha256-GSK12dIrtMnz4O77G6Rg/YBGxmlQrm+4+XodM6MbBs0=";
          name = "icons-carbon";
          publisher = "antfu";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      antfu.slidev = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "52.15.0";
          hash = "sha256-iCOLP2ZOm/kwmNFrmc9NJi1nU+301y2Jgnj9FbUSbm0=";
          name = "slidev";
          publisher = "antfu";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      anthropic.claude-code = callPackage ./anthropic.claude-code { };

      antyos.openscad = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.3.2";
          hash = "sha256-1hEUBJW4QNq0ECO9Mwk4OCDxu4VQ+ZvMrj2rRna51Gc=";
          name = "openscad";
          publisher = "Antyos";
        };

        meta = {
          description = "OpenSCAD highlighting, snippets, and more for VSCode";
          homepage = "https://github.com/Antyos/vscode-openscad";
          changelog = "https://marketplace.visualstudio.com/items/Antyos.openscad/changelog";
          license = lib.licenses.gpl3;
        };
      };

      anweber.vscode-httpyac = callPackage ./anweber.vscode-httpyac { };

      apollographql.vscode-apollo = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.6.6";
          hash = "sha256-rvLZoLY0P031ZAjeYXNqPVYwRNkCRYUvedosxM51opc=";
          name = "vscode-apollo";
          publisher = "apollographql";
        };

        meta = {
          description = "Rich editor support for GraphQL client and server development that seamlessly integrates with the Apollo platform";
          homepage = "https://github.com/apollographql/vscode-graphql";
          changelog = "https://marketplace.visualstudio.com/items/apollographql.vscode-apollo/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.datafoo ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=apollographql.vscode-apollo";
        };
      };

      arcticicestudio.nord-visual-studio-code = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.19.0";
          hash = "sha256-awbqFv6YuYI0tzM/QbHRTUl4B2vNUdy52F4nPmv+dRU=";
          name = "nord-visual-studio-code";
          publisher = "arcticicestudio";
        };

        meta = {
          description = "Arctic, north-bluish clean and elegant Visual Studio Code theme";
          homepage = "https://github.com/arcticicestudio/nord-visual-studio-code";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.imgabe ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=arcticicestudio.nord-visual-studio-code";
        };
      };

      arjun.swagger-viewer = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.1.2";
          name = "swagger-viewer";
          publisher = "Arjun";
          sha256 = "1cjvc99x1q5w3i2vnbxrsl5a1dr9gb3s6s9lnwn6mq5db6iz1nlm";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      arrterian.nix-env-selector = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.3.1";
          hash = "sha256-dV1FkAOZkWgqlk6j6ppQSUz5N3AoGTPgPkep60gGeP8=";
          name = "nix-env-selector";
          publisher = "arrterian";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      asciidoctor.asciidoctor-vscode = callPackage ./asciidoctor.asciidoctor-vscode { };

      asdine.cue = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.3.4";
          hash = "sha256-X+CFRKAZmjzf5dkE/AGd3A/voX/XHfMP5WEt8sJll8U=";
          name = "cue";
          publisher = "asdine";
        };

        meta = {
          description = "Cue language support for Visual Studio Code";
          homepage = "https://github.com/asdine/vscode-cue";
          changelog = "https://marketplace.visualstudio.com/items/asdine.cue/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.matthewpi ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=asdine.cue";
        };
      };

      astro-build.astro-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.16.17";
          hash = "sha256-k54hpRlzjtNWv0mIUBKFxJYc5T2jpWxB9U8nuXXmjJ0=";
          name = "astro-vscode";
          publisher = "astro-build";
        };

        meta = {
          description = "Astro language support for VS Code";
          homepage = "https://github.com/withastro/language-tools";
          changelog = "https://marketplace.visualstudio.com/items/astro-build.astro-vscode/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=astro-build.astro-vscode";
        };
      };

      asvetliakov.vscode-neovim = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.19.0";
          hash = "sha256-PTuOqbvhN2lutShMn76uxune/gd5sTc5KSfA2xLhmH8=";
          name = "vscode-neovim";
          publisher = "asvetliakov";
        };

        meta = {
          description = "Vim-mode for VS Code using embedded Neovim";
          homepage = "https://github.com/vscode-neovim/vscode-neovim";
          changelog = "https://marketplace.visualstudio.com/items/asvetliakov.vscode-neovim/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.mikaelfangel ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=asvetliakov.vscode-neovim";
        };
      };

      attilabuti.brainfuck-syntax = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.1";
          hash = "sha256-ZcZlHoa2aoCeruMWbUUgfFHsPqyWmd2xFY6AKxJysYE=";
          name = "brainfuck-syntax";
          publisher = "attilabuti";
        };

        meta = {
          description = "VSCode extension providing syntax highlighting support for Brainfuck";
          homepage = "https://github.com/attilabuti/brainfuck-syntax";
          changelog = "https://marketplace.visualstudio.com/items/attilabuti.brainfuck-syntax/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=attilabuti.brainfuck-syntax";
        };
      };

      augment.vscode-augment = callPackage ./augment.vscode-augment { };
      azdavis.millet = callPackage ./azdavis.millet { };
      b4dm4n.vscode-nixpkgs-fmt = callPackage ./b4dm4n.vscode-nixpkgs-fmt { };

      baccata.scaladex-search = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.3.5";
          hash = "sha256-ff4mqEqO07z/pV2U/R4NsFW7czG+5+M/a2x7vv1ly7E=";
          name = "scaladex-search";
          publisher = "baccata";
        };

        meta = {
          license = lib.licenses.asl20;
        };
      };

      badochov.ocaml-formatter = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.0.5";
          hash = "sha256-D04EJButnam/l4aAv1yNbHlTKMb3x1yrS47+9XjpCLI=";
          name = "ocaml-formatter";
          publisher = "badochov";
        };

        meta = {
          description = "VSCode Extension Formatter for OCaml language";
          homepage = "https://github.com/badochov/ocamlformatter-vscode";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=badochov.ocaml-formatter";
        };
      };

      ban.spellright = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.0.154";
          hash = "sha256-vGzmzY78FOS8ZsrT1YpTNOUJprW4rZHVuM83cZz6V+Q=";
          name = "spellright";
          publisher = "ban";
        };

        meta = {
          description = "Visual Studio Code extension for Spellchecker";
          homepage = "https://github.com/bartosz-antosik/vscode-spellright";
          changelog = "https://marketplace.visualstudio.com/items/ban.spellright/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ onedragon ];
        };
      };

      banacorn.agda-mode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.10.0";
          hash = "sha256-rz3Ehq/2AewE5ADYHVk8pHICSWO58i8v+nBwzkFkGCY=";
          name = "agda-mode";
          publisher = "banacorn";
        };

        meta = {
          description = "agda-mode on VS Code";
          homepage = "https://github.com/banacorn/agda-mode-vscode";
          changelog = "https://marketplace.visualstudio.com/items/banacorn.agda-mode/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ Anillc ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=banacorn.agda-mode";
        };
      };

      batisteo.vscode-django = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.15.0";
          hash = "sha256-WBZsZNcq9OY30uaksfcRmCvHcugemMhsJ6d6/IncR5s=";
          name = "vscode-django";
          publisher = "batisteo";
        };

        meta = {
          description = "Django extension for Visual Studio Code";
          homepage = "https://github.com/vscode-django/vscode-django";
          changelog = "https://marketplace.visualstudio.com/items/batisteo.vscode-django/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ azd325 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=batisteo.vscode-django";
        };
      };

      bazelbuild.vscode-bazel = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.14.0";
          name = "vscode-bazel";
          publisher = "bazelbuild";
          sha256 = "sha256-JrXx/ICXQPlAKh7m6+eWWQ2bP1Nfls4PbW426PNJVBc=";
        };

        meta = {
          description = "Bazel support for Visual Studio Code";
          homepage = "https://github.com/bazelbuild/vscode-bazel";
          license = lib.licenses.asl20;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=BazelBuild.vscode-bazel";
        };
      };

      bbenoist.nix = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.1";
          name = "Nix";
          publisher = "bbenoist";
          sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      benfradet.vscode-unison = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.4.0";
          hash = "sha256-IDM9v+LWckf20xnRTj+ThAFSzVxxDVQaJkwO37UIIhs=";
          name = "vscode-unison";
          publisher = "benfradet";
        };

        meta = {
          license = lib.licenses.asl20;
        };
      };

      betterthantomorrow.calva = callPackage ./betterthantomorrow.calva { };
      bierner.color-info = callPackage ./bierner.color-info { };

      bierner.comment-tagged-templates = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.4.0";
          hash = "sha256-mI2VogA6JVEfFL5B3+Od23//uPmXeqP8Om2AnhCs2Hs=";
          name = "comment-tagged-templates";
          publisher = "bierner";
        };

        meta = {
          description = "VS Code extension that adds basic syntax highlighting for JavaScript and TypeScript tagged template strings using language identifier comments";
          homepage = "https://github.com/mjbvz/vscode-comment-tagged-templates";
          changelog = "https://marketplace.visualstudio.com/items/bierner.comment-tagged-templates/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bierner.comment-tagged-templates";
        };
      };

      bierner.docs-view = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.0";
          hash = "sha256-Y5bQVb0OuhHvpvZPXlJRe17qSN3tzqm8JwS6nO2tG7g=";
          name = "docs-view";
          publisher = "bierner";
        };

        meta = {
          description = "VSCode extension that displays documentation in the sidebar or panel";
          homepage = "https://github.com/mattbierner/vscode-docs-view#readme";
          changelog = "https://marketplace.visualstudio.com/items/bierner.docs-view/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bierner.docs-view";
        };
      };

      bierner.emojisense = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.10.0";
          hash = "sha256-PD8edYuJu6QHPYIM08kV85LuKh0H0/MIgFmMxSJFK5M=";
          name = "emojisense";
          publisher = "bierner";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      bierner.github-markdown-preview = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.4.0";
          hash = "sha256-bfj0rrZWVtgNfynap9+kdp8jAef0g9pTozEJwmkzhgU=";
          name = "github-markdown-preview";
          publisher = "bierner";
        };

        meta = {
          description = "VSCode extension that changes the markdown preview to support GitHub markdown features";
          homepage = "https://github.com/mjbvz/vscode-github-markdown-preview";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.pandapip1 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bierner.github-markdown-preview";
        };
      };

      bierner.markdown-checkbox = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.4.0";
          hash = "sha256-AoPcdN/67WOzarnF+GIx/nans38Jan8Z5D0StBWIbkk=";
          name = "markdown-checkbox";
          publisher = "bierner";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      bierner.markdown-emoji = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.3.1";
          hash = "sha256-gfdEwKXLSu54M1gApM1Y1jofAtTdmg5UuBT8f/TUCRA=";
          name = "markdown-emoji";
          publisher = "bierner";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      bierner.markdown-footnotes = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.1";
          hash = "sha256-h/Iyk8CKFr0M5ULXbEbjFsqplnlN7F+ZvnUTy1An5t4=";
          name = "markdown-footnotes";
          publisher = "bierner";
        };

        meta = {
          description = "Adds [^1] footnote syntax support to VS Code's built-in Markdown preview";
          homepage = "https://github.com/mjbvz/vscode-markdown-footnotes";
          changelog = "https://marketplace.visualstudio.com/items/bierner.markdown-footnotes/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bierner.markdown-footnotes";
        };
      };

      bierner.markdown-mermaid = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.32.1";
          hash = "sha256-bH8JBZOfj2Km5/tfaiSzrkOl2kOU+XwZcuWOpU9iVEM=";
          name = "markdown-mermaid";
          publisher = "bierner";
        };

        meta = {
          description = "Adds Mermaid diagram and flowchart support to VS Code's builtin markdown preview";
          homepage = "https://github.com/mjbvz/vscode-markdown-mermaid";
          changelog = "https://marketplace.visualstudio.com/items/bierner.markdown-mermaid/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid";
        };
      };

      bierner.markdown-preview-github-styles = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.2.0";
          hash = "sha256-Jg8XpMoSVZA/VpQhLY3bmmG9pb0XL2CRlhlemcWvzSg=";
          name = "markdown-preview-github-styles";
          publisher = "bierner";
        };

        meta = {
          description = "Changes VS Code's built-in markdown preview to match GitHub's styling";
          homepage = "https://github.com/mjbvz/vscode-github-markdown-preview-style";
          changelog = "https://marketplace.visualstudio.com/items/bierner.markdown-preview-github-styles/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bierner.markdown-preview-github-styles";
        };
      };

      biomejs.biome = callPackage ./biomejs.biome { };

      bmalehorn.vscode-fish = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.49";
          hash = "sha256-oG0KOvQZ2E5FroXaUT6lGw1zDSQ/bisHLMMkygbGqQE=";
          name = "vscode-fish";
          publisher = "bmalehorn";
        };

        meta = {
          description = "Fish syntax highlighting and formatting for VS Code";
          homepage = "https://github.com/bmalehorn/vscode-fish";
          changelog = "https://marketplace.visualstudio.com/items/bmalehorn.vscode-fish/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bmalehorn.vscode-fish";
        };
      };

      bmewburn.vscode-intelephense-client = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.18.5";
          hash = "sha256-yLp7lBWjdH+KtBUlkjLWz5OmAvEQWJFIVCVsBt9BTeE=";
          name = "vscode-intelephense-client";
          publisher = "bmewburn";
        };

        meta = {
          description = "PHP code intelligence for Visual Studio Code";
          license = lib.licenses.unfree;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bmewburn.vscode-intelephense-client";
        };
      };

      bodil.blueprint-gtk = callPackage ./bodil.blueprint-gtk { };

      bodil.file-browser = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.11";
          hash = "sha256-yPVhhsAUZxnlhj58fXkk+yhxop2q7YJ6X4W9dXGKJfo=";
          name = "file-browser";
          publisher = "bodil";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      bradgashler.htmltagwrap = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.0";
          hash = "sha256-WOMfwxyeDLoSwF0xz9tbntDVrUWycJ4bW0rZjfLSzgM=";
          name = "htmltagwrap";
          publisher = "bradgashler";
        };

        meta = {
          description = "VSCode extension for wrapping a text selection in HTML tags";
          homepage = "https://github.com/bgashler1/vscode-htmltagwrap";
          changelog = "https://github.com/bgashler1/vscode-htmltagwrap/blob/master/CHANGELOG.md";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bradgashler.htmltagwrap";
        };
      };

      bradlc.vscode-tailwindcss = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.14.29";
          hash = "sha256-58/yM4xP8ewpegNlVSWnyFIoAmEd7E/CigQgae7OgZY=";
          name = "vscode-tailwindcss";
          publisher = "bradlc";
        };

        meta = {
          description = "Tailwind CSS tooling for Visual Studio Code";
          homepage = "https://github.com/tailwindlabs/tailwindcss-intellisense";
          changelog = "https://marketplace.visualstudio.com/items/bradlc.vscode-tailwindcss/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bradlc.vscode-tailwindcss";
        };
      };

      brandonkirbyson.solarized-palenight = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.1";
          hash = "sha256-vVbaHSaBX6QzpnYMQlpPsJU1TQYJEBe8jq95muzwN0o=";
          name = "solarized-palenight";
          publisher = "BrandonKirbyson";
        };

        meta = {
          description = "Solarized-palenight theme for vscode";
          homepage = "https://github.com/BrandonKirbyson/Solarized-Palenight";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=BrandonKirbyson.solarized-palenight";
        };
      };

      brettm12345.nixfmt-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.1";
          name = "nixfmt-vscode";
          publisher = "brettm12345";
          sha256 = "07w35c69vk1l6vipnq3qfack36qcszqxn8j3v332bl0w6m02aa7k";
        };

        meta = {
          license = lib.licenses.mpl20;
        };
      };

      budparr.language-hugo-vscode = callPackage ./budparr.language-hugo-vscode { };

      bungcip.better-toml = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.3.2";
          hash = "sha256-g+LfgjAnSuSj/nSmlPdB0t29kqTmegZB5B1cYzP8kCI=";
          name = "better-toml";
          publisher = "bungcip";
        };

        meta = {
          description = "Better TOML Language support";
          homepage = "https://github.com/bungcip/better-toml/blob/master/README.md";
          changelog = "https://marketplace.visualstudio.com/items/bungcip.better-toml/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.datafoo ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=bungcip.better-toml";
        };
      };

      cameron.vscode-pytest = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.1";
          hash = "sha256-YU37a0Q+IXusXgwf9doxXLlYiyzkizbPjjdCZFxeDaA=";
          name = "vscode-pytest";
          publisher = "Cameron";
        };

        meta = {
          description = "Visual Studio Code extension that adds IntelliSense support for pytest fixtures";
          changelog = "https://github.com/cameronmaske/pytest-vscode/blob/master/CHANGELOG.md";
          license = lib.licenses.unlicense;
          maintainers = [ lib.maintainers.rhoriguchi ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Cameron.vscode-pytest";
        };
      };

      capatech.betacode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.10";
          hash = "sha256-Sq+s1dM+gZo73VaGEAX88fgVRAhWklg0LKv+yH46Jfw=";
          name = "betacode";
          publisher = "capatech";
        };

        meta = {
          description = "VSCode extension for writing polytonic Greek";
          homepage = "https://github.com/kugland/vscode-extension-betacode";
          license = lib.licenses.gpl3;
          maintainers = with lib.maintainers; [ thtrf ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Capatech.betacode";
        };
      };

      carrie999.cyberpunk-2020 = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.4";
          hash = "sha256-tVbd+j9+90Z07+jGAiT0gylZN9YWHdJmq2sh1wf2oGE=";
          name = "cyberpunk-2020";
          publisher = "carrie999";
        };

        meta = {
          description = "Cyberpunk-inspired colour theme to satisfy your neon dreams";
          homepage = "https://github.com/Carrie999/cyberpunk";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=carrie999.cyberpunk-2020";
        };
      };

      castwide.solargraph = callPackage ./castwide.solargraph { };

      catppuccin = {
        catppuccin-vsc = buildVscodeMarketplaceExtension {
          mktplcRef = {
            version = "3.19.0";
            hash = "sha256-6/NHZkg37b6RyZIP89FMltSii+7sC5UTfHYFgyYyl4A=";
            name = "catppuccin-vsc";
            publisher = "catppuccin";
          };

          meta = {
            description = "Soothing pastel theme for VSCode";
            homepage = "https://github.com/catppuccin/vscode";
            changelog = "https://marketplace.visualstudio.com/items/Catppuccin.catppuccin-vsc/changelog";
            license = lib.licenses.mit;
            maintainers = [ ];
            downloadPage = "https://marketplace.visualstudio.com/items?itemName=Catppuccin.catppuccin-vsc";
          };
        };

        catppuccin-vsc-icons = buildVscodeMarketplaceExtension {
          mktplcRef = {
            version = "1.26.0";
            hash = "sha256-V1ZhNtCouo0EDrblvoZsiMy7BPPSGdOn5SoZl4kA/z0=";
            name = "catppuccin-vsc-icons";
            publisher = "catppuccin";
          };

          meta = {
            description = "Soothing pastel icon theme for VSCode";
            homepage = "https://github.com/catppuccin/vscode-icons";
            changelog = "https://marketplace.visualstudio.com/items/Catppuccin.catppuccin-vsc-icons/changelog";
            license = lib.licenses.mit;
            maintainers = [ ];
            downloadPage = "https://marketplace.visualstudio.com/items?itemName=Catppuccin.catppuccin-vsc-icons";
          };
        };
      };

      chanhx.crabviz = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.5.0";
          hash = "sha256-YLNx/9jmHc0HDm/yHquOlMDPmAbpIdd6UZn0JZQVJko=";
          name = "crabviz";
          publisher = "chanhx";
        };

        meta = {
          description = "VSCode extension for generating call graphs based on LSP";
          homepage = "https://github.com/chanhx/crabviz";
          license = lib.licenses.asl20;
          maintainers = with lib.maintainers; [ thtrf ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=chanhx.crabviz";
        };
      };

      charliermarsh.ruff = callPackage ./charliermarsh.ruff { };
      chenglou92.rescript-vscode = callPackage ./chenglou92.rescript-vscode { };

      chris-hayes.chatgpt-reborn = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.28.0";
          name = "chatgpt-reborn";
          publisher = "chris-hayes";
          sha256 = "sha256-YOaOBDGoLg/bWB/Yw6CCbJ/J7s6qA8QlbM3wiknCTGQ=";
        };

        meta = {
          description = "Visual Studio Code extension to support ChatGPT, GPT-3 and Codex conversations";
          homepage = "https://github.com/christopher-hayes/vscode-chatgpt-reborn";
          changelog = "https://marketplace.visualstudio.com/items/chris-hayes.chatgpt-reborn/changelog";
          license = lib.licenses.isc;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=chris-hayes.chatgpt-reborn";
        };
      };

      chrischinchilla.vscode-pandoc = callPackage ./chrischinchilla.vscode-pandoc { };

      christian-kohler.npm-intellisense = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.4.5";
          name = "npm-intellisense";
          publisher = "christian-kohler";
          sha256 = "962b851a7cafbd51f34afeb4a0b91e985caff3947e46218a12b448533d8f60ab";
        };

        meta = {
          description = "Visual Studio Code plugin that autocompletes npm modules in import statements";
          homepage = "https://github.com/ChristianKohler/NpmIntellisense";
          changelog = "https://marketplace.visualstudio.com/items/christian-kohler.npm-intellisense/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.DataHearth ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=christian-kohler.npm-intellisense";
        };
      };

      christian-kohler.path-intellisense = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.10.0";
          name = "path-intellisense";
          publisher = "christian-kohler";
          sha256 = "sha256-bE32VmzZBsAqgSxdQAK9OoTcTgutGEtgvw6+RaieqRs=";
        };

        meta = {
          description = "Visual Studio Code plugin that autocompletes filenames";
          homepage = "https://github.com/ChristianKohler/PathIntellisense";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.imgabe ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=christian-kohler.path-intellisense";
        };
      };

      claui.packaging = callPackage ./claui.packaging { };

      cmschuetz12.wal = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.0";
          name = "wal";
          publisher = "cmschuetz12";
          sha256 = "0q089jnzqzhjfnv0vlb5kf747s3mgz64r7q3zscl66zb2pz5q4zd";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      coder.coder-remote = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.15.2";
          hash = "sha256-mBACvGUQF3LoaFJ9MIewN9zu4jDTWfUgyd1MQvZQUvk=";
          name = "coder-remote";
          publisher = "coder";
        };

        meta = {
          description = "Extension for Visual Studio Code to open any Coder workspace in VS Code with a single click";
          homepage = "https://github.com/coder/vscode-coder";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=coder.coder-remote";
        };
      };

      codezombiech.gitignore = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.10.0";
          hash = "sha256-WTKVHrhBeAocP+stskFsSFtd0aR3u1TTEMYtdxj1tlY=";
          name = "gitignore";
          publisher = "codezombiech";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      colejcummins.llvm-syntax-highlighting = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.3";
          hash = "sha256-D5zLp3ruq0F9UFT9emgOBDLr1tya2Vw52VvCc40TtV0=";
          name = "llvm-syntax-highlighting";
          publisher = "colejcummins";
        };

        meta = {
          description = "Lightweight syntax highlighting for LLVM IR";
          homepage = "https://github.com/colejcummins/llvm-syntax-highlighting";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.inclyc ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=colejcummins.llvm-syntax-highlighting";
        };
      };

      congyiwu.vscode-jupytext = callPackage ./congyiwu.vscode-jupytext { };

      contextmapper.context-mapper-vscode-extension =
        callPackage ./contextmapper.context-mapper-vscode-extension
          { };

      continue.continue = callPackage ./continue.continue { };

      coolbear.systemd-unit-file = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.6";
          name = "systemd-unit-file";
          publisher = "coolbear";
          sha256 = "0sc0zsdnxi4wfdlmaqwb6k2qc21dgwx6ipvri36x7agk7m8m4736";
        };

        meta = {
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.kamadorueda ];
        };
      };

      csharpier.csharpier-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "10.0.3";
          hash = "sha256-YTDpBGLbyM6Nq5DlEtqFiSsSRRECLIEqSM4xgIIVWG0=";
          name = "csharpier-vscode";
          publisher = "csharpier";
        };

        meta = {
          description = "CSharpier code formatter for Visual Studio Code";
          homepage = "https://github.com/belav/csharpier";
          changelog = "https://marketplace.visualstudio.com/items/csharpier.csharpier-vscode/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.magnouvean ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=csharpier.csharpier-vscode";
        };
      };

      cuelangorg.vscode-cue = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.19";
          hash = "sha256-Ktefsmgs/p6aV6meEMxuzRizIh4xfjTI9z9pqewyvpg=";
          name = "vscode-cue";
          publisher = "cuelangorg";
        };

        meta = {
          description = "The offical CUE extension for VS Code, providing syntax highlighting and language server integration (LSP)";
          homepage = "https://github.com/cue-lang/vscode-cue";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.karaolidis ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=cuelangorg.vscode-cue";
        };
      };

      cweijan.dbclient-jdbc = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.4.6";
          hash = "sha256-989egeJlpJ2AfZra9VSQDQ8e+nQCa2sfoUeti674ecA=";
          name = "dbclient-jdbc";
          publisher = "cweijan";
        };

        meta = {
          description = "JDBC Adapter For Database Client";
          homepage = "https://github.com/database-client/jdbc-adapter-server";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=cweijan.dbclient-jdbc";
        };
      };

      cweijan.vscode-database-client2 = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "9.0.2";
          hash = "sha256-RCjtYpGDEjFkKvTspvgopccNVvMt1imeAGHZYRsle/Q=";
          name = "vscode-database-client2";
          publisher = "cweijan";
        };

        meta = {
          description = "Database Client For Visual Studio Code";
          homepage = "https://marketplace.visualstudio.com/items?itemName=cweijan.vscode-mysql-client2";
          license = lib.licenses.mit;
        };
      };

      danielgavin.ols = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.46";
          hash = "sha256-X2Tp0rsPp0UoKW4Yz7Ht/7b1zO0bL92u6CtyKRy+hDY=";
          name = "ols";
          publisher = "DanielGavin";
        };

        meta = {
          description = "Visual Studio Code extension for Odin language";
          homepage = "https://github.com/DanielGavin/ols";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=DanielGavin.ols";
        };
      };

      danielsanmedium.dscodegpt = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.23.1";
          hash = "sha256-B97cImVKnholhZV0ZBru/gpeVSaTHOFfQywwmjk+kq8=";
          name = "dscodegpt";
          publisher = "DanielSanMedium";
        };

        meta = {
          description = "Easily connect to AI providers using their official APIs in VSCode";
          homepage = "https://codegpt.co";
          changelog = "https://marketplace.visualstudio.com/items/DanielSanMedium.dscodegpt/changelog";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers.onny ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=DanielSanMedium.dscodegpt";
        };
      };

      daohong-emilio.yash = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.3.1";
          hash = "sha256-DentLM/XT7b7O4vptVcja9E8pQjiDPOLilo8wjTH0IE=";
          name = "yash";
          publisher = "daohong-emilio";
        };

        meta = {
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.kamadorueda ];
        };
      };

      dart-code.dart-code = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.136.1";
          hash = "sha256-z9DPxEtQwjx9xk5ucHKfX2BYRij5UA253oPuHpD0jdU=";
          name = "dart-code";
          publisher = "dart-code";
        };

        meta.license = lib.licenses.mit;
      };

      dart-code.flutter = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.138.0";
          hash = "sha256-FkaUKApoN6e8ET2o/71GVhyNWdZ34t6fqEzlraH7QBc=";
          name = "flutter";
          publisher = "dart-code";
        };

        meta.license = lib.licenses.mit;
      };

      databricks.databricks = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.12.1";
          hash = "sha256-GKm3rZMvU/5Ii01GjUg7rE15TnOtDTh0LwkDVsuSLfY=";
          name = "databricks";
          publisher = "databricks";
        };

        meta = {
          description = "Databricks extension for Visual Studio Code";
          homepage = "https://github.com/databricks/databricks-vscode";
          changelog = "https://marketplace.visualstudio.com/items/databricks.databricks/changelog";
          license = lib.licenses.databricks-license;
          maintainers = [ lib.maintainers.softinio ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=databricks.databricks";
        };
      };

      davidanson.vscode-markdownlint = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.61.2";
          hash = "sha256-RGWgY6pyq7j509UjLD3SSyOOA7cXGFFk95H1hoeKPjA=";
          name = "vscode-markdownlint";
          publisher = "DavidAnson";
        };

        meta = {
          description = "Markdown linting and style checking for Visual Studio Code";
          homepage = "https://github.com/DavidAnson/vscode-markdownlint";
          changelog = "https://marketplace.visualstudio.com/items/DavidAnson.vscode-markdownlint/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.datafoo ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint";
        };
      };

      davidlday.languagetool-linter = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.25.8";
          hash = "sha256-ddDxe0ZJgQjDUAKAQyboHEi0ZeVBeGE4Zx2peRbBGFA=";
          name = "languagetool-linter";
          publisher = "davidlday";
        };

        meta = {
          description = "LanguageTool integration for VS Code";
          homepage = "https://github.com/davidlday/vscode-languagetool-linter";
          license = lib.licenses.asl20;
          maintainers = [ lib.maintainers.ebbertd ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=davidlday.languagetool-linter";
        };
      };

      dbaeumer.vscode-eslint = callPackage ./dbaeumer.vscode-eslint { };
      dendron.adjust-heading-level = callPackage ./dendron.adjust-heading-level { };
      dendron.dendron = callPackage ./dendron.dendron { };
      dendron.dendron-paste-image = callPackage ./dendron.dendron-paste-image { };
      dendron.dendron-snippet-maker = callPackage ./dendron.dendron-snippet-maker { };

      denoland.vscode-deno = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.53.0";
          hash = "sha256-M+wFee1x/cCgGMFrDaV7OtIhEORHkLHf/Z06/VuZZmg=";
          name = "vscode-deno";
          publisher = "denoland";
        };

        meta = {
          description = "Language server client for Deno";
          homepage = "https://github.com/denoland/vscode_deno";
          changelog = "https://marketplace.visualstudio.com/items/denoland.vscode-deno/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.ratsclub ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=denoland.vscode-deno";
        };
      };

      detachhead.basedpyright = callPackage ./detachhead.basedpyright { };

      dhall.dhall-lang = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.4";
          name = "dhall-lang";
          publisher = "dhall";
          sha256 = "0sa04srhqmngmw71slnrapi2xay0arj42j4gkan8i11n7bfi1xpf";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      dhall.vscode-dhall-lsp-server = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.4";
          name = "vscode-dhall-lsp-server";
          publisher = "dhall";
          sha256 = "1zin7s827bpf9yvzpxpr5n6mv0b5rhh3civsqzmj52mdq365d2js";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      dhedgecock.radical-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.3.1";
          hash = "sha256-VvFQovuE+I0lqXU9fHrmk7nWMpuuWafqm9Acwb0+QYg=";
          name = "radical-vscode";
          publisher = "dhedgecock";
        };

        meta = {
          description = "Dark theme for radical hacking inspired by retro futuristic design";
          homepage = "https://github.com/dhedgecock/radical-vscode";
          changelog = "https://marketplace.visualstudio.com/items/dhedgecock.radical-vscode/changelog";
          license = lib.licenses.isc;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=dhedgecock.radical-vscode";
        };
      };

      discloud.discloud = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.29.8";
          hash = "sha256-dvyIdixtmg5ZTo/REB/E5QlHJu2xZ+Ui5qwJegoHTfk=";
          name = "discloud";
          publisher = "discloud";
        };

        meta = {
          description = "Visual Studio Code extension for hosting and managing applications on Discloud";
          homepage = "https://github.com/discloud/vscode-discloud";
          changelog = "https://marketplace.visualstudio.com/items/discloud.discloud/changelog";
          license = lib.licenses.asl20;
          maintainers = [ lib.maintainers.diogomdp ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=discloud.discloud";
        };
      };

      disneystreaming.smithy = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.14";
          hash = "sha256-dnHaJRlFd535Gi3T1+0YBOnytmf2W15Vta5H6HhzYZI=";
          name = "smithy";
          publisher = "disneystreaming";
        };

        meta = {
          license = lib.licenses.asl20;
        };
      };

      divyanshuagrawal.competitive-programming-helper = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2026.6.1780853884";
          hash = "sha256-4nxH5qW3u3/9Vqf+QFs7l5BDusE5wcxxHiJFcPq/2EE=";
          name = "competitive-programming-helper";
          publisher = "DivyanshuAgrawal";
        };

        meta = {
          description = "Makes judging, compiling, and downloading problems for competitve programming easy. Also supports auto-submit for a few sites";
          homepage = "https://github.com/agrawal-d/cph";
          changelog = "https://marketplace.visualstudio.com/items/DivyanshuAgrawal.competitive-programming-helper/changelog";
          license = lib.licenses.gpl3;
          maintainers = [ lib.maintainers.arcticlimer ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=DivyanshuAgrawal.competitive-programming-helper";
        };
      };

      docker.docker = callPackage ./docker.docker { };

      donjayamanne.githistory = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.6.20";
          hash = "sha256-nEdYS9/cMS4dcbFje23a47QBZr9eDK3dvtkFWqA+OHU=";
          name = "githistory";
          publisher = "donjayamanne";
        };

        meta = {
          description = "View git log, file history, compare branches or commits";
          homepage = "https://github.com/DonJayamanne/gitHistoryVSCode/";
          changelog = "https://marketplace.visualstudio.com/items/donjayamanne.githistory/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=donjayamanne.githistory";
        };
      };

      dotenv.dotenv-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.28.1";
          hash = "sha256-Ye3T/u/2mmezAi1ErtJBX7M/3rAb7Mc3wvMGJaX3r5s=";
          name = "dotenv-vscode";
          publisher = "dotenv";
        };

        meta = {
          description = "Official Dotenv extension for VSCode. Offers syntax highlighting, auto-cloaking, auto-completion, in-code secret peeking, and optionally dotenv-vault";
          homepage = "https://github.com/dotenv-org/dotenv-vscode";
          changelog = "https://marketplace.visualstudio.com/items/dotenv.dotenv-vscode/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=dotenv.dotenv-vscode";
        };
      };

      dotjoshjohnson.xml = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.5.1";
          name = "xml";
          publisher = "dotjoshjohnson";
          sha256 = "1v4x6yhzny1f8f4jzm4g7vqmqg5bqchyx4n25mkgvw2xp6yls037";
        };

        meta = {
          description = "XML Tools";
          homepage = "https://github.com/DotJoshJohnson/vscode-xml";
          license = lib.licenses.mit;
        };
      };

      dracula-theme.theme-dracula = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.25.1";
          hash = "sha256-ijGbdiqbDQmZYVqZCx2X4W7KRNV3UDddWvz+9x/vfcA=";
          name = "theme-dracula";
          publisher = "dracula-theme";
        };

        meta = {
          description = "Dark theme for many editors, shells, and more";
          homepage = "https://draculatheme.com/";
          changelog = "https://marketplace.visualstudio.com/items/dracula-theme.theme-dracula/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=dracula-theme.theme-dracula";
        };
      };

      drblury.protobuf-vsc = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.6.6";
          hash = "sha256-uMyxdLptaLZBlLEugvYQgJTZCtysmnZix9faXsQfHGk=";
          name = "protobuf-vsc";
          publisher = "DrBlury";
        };

        meta = {
          description = "Comprehensive Protocol Buffers support with syntax highlighting, IntelliSense, diagnostics and formatting";
          homepage = "https://github.com/DrBlury/protobuf-vsc-extension";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=DrBlury.protobuf-vsc";
        };
      };

      eamodio.gitlens = callPackage ./eamodio.gitlens { };

      earthly.earthfile-syntax-highlighting = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.16";
          name = "earthfile-syntax-highlighting";
          publisher = "earthly";
          sha256 = "c54d6fd4d2f503a1031be92ff118b5eb1b997907511734e730e08b1a90a6960f";
        };

        meta = {
          description = "Syntax highlighting for Earthly build Earthfiles";
          homepage = "https://github.com/earthly/earthfile-grammar";
          changelog = "https://marketplace.visualstudio.com/items/earthly.earthfile-syntax-highlighting/changelog";
          license = lib.licenses.mpl20;
          maintainers = [ lib.maintainers.DataHearth ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=earthly.earthfile-syntax-highlighting";
        };
      };

      ecmel.vscode-html-css = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.0.14";
          hash = "sha256-0IAwX/KPh1CKCQENcztDnCkbYDWipO09zl3Qcb1RPfA=";
          name = "vscode-html-css";
          publisher = "ecmel";
        };

        meta = {
          description = "CSS Intellisense for HTML";
          homepage = "https://github.com/ecmel/vscode-html-css";
          changelog = "https://marketplace.visualstudio.com/items/ecmel.vscode-html-css/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.DataHearth ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ecmel.vscode-html-css";
        };
      };

      editorconfig.editorconfig = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.18.2";
          hash = "sha256-y8A3D/IEvBbYSj7mgwU2/AQ1WFb6DolasGThoDz8uEo=";
          name = "editorconfig";
          publisher = "editorconfig";
        };

        meta = {
          description = "EditorConfig Support for Visual Studio Code";
          homepage = "https://github.com/editorconfig/editorconfig-vscode";
          changelog = "https://marketplace.visualstudio.com/items/EditorConfig.EditorConfig/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.dbirks ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig";
        };
      };

      edonet.vscode-command-runner = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.124";
          hash = "sha256-a59xTFbLoy13V4DUqd7vIJWcJ9+eoBM0SOo51rR1r+Y=";
          name = "vscode-command-runner";
          publisher = "edonet";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      eg2.vscode-npm-script = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.3.29";
          hash = "sha256-k6DtmhYBj7mg8SUU3pg+ezRzWvhiECqYQVj9LDhhV4I=";
          name = "vscode-npm-script";
          publisher = "eg2";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      egirlcatnip.adwaita-github-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.6";
          hash = "sha256-6xooF8petGLn8Zlh8rCXG2RJdAcdt8t8GPwhfgc5Gxs=";
          name = "adwaita-github-theme";
          publisher = "egirlcatnip";
        };

        meta = {
          description = "Adwaita VS Code theme with Github syntax highlighting";
          homepage = "https://github.com/egirlcatnip/adwaita-github-theme";
          license = lib.licenses.gpl3;
          maintainers = with lib.maintainers; [ thtrf ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=egirlcatnip.adwaita-github-theme";
        };
      };

      elijah-potter.harper = callPackage ./elijah-potter.harper { };

      elixir-lsp.vscode-elixir-ls = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.31.1";
          hash = "sha256-eF0OGWpiu5aDiFp8MFP7j2r2+3QCPb1q93gWg7L/Xzc=";
          name = "elixir-ls";
          publisher = "JakeBecker";
        };

        meta = {
          description = "Elixir support with debugger, autocomplete, and more. Powered by ElixirLS";
          homepage = "https://github.com/elixir-lsp/elixir-ls";
          changelog = "https://marketplace.visualstudio.com/items/JakeBecker.elixir-ls/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.datafoo ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=JakeBecker.elixir-ls";
        };
      };

      elmtooling.elm-ls-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.8.0";
          hash = "sha256-81tHgNjYc0LJjsgsQfo5xyh20k/i3PKcgYp9GZTvwfs=";
          name = "elm-ls-vscode";
          publisher = "Elmtooling";
        };

        meta = {
          description = "Elm language server";
          homepage = "https://github.com/elm-tooling/elm-language-client-vscode";
          changelog = "https://marketplace.visualstudio.com/items/Elmtooling.elm-ls-vscode/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.mcwitt ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Elmtooling.elm-ls-vscode";
        };
      };

      emmanuelbeziat.vscode-great-icons = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.1.121";
          hash = "sha256-5PAOxy+9KnATEf7BlrAV8cE+xFvfQVSyv7Dov9mqWI0=";
          name = "vscode-great-icons";
          publisher = "emmanuelbeziat";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      emroussel.atomize-atom-one-dark-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.0.2";
          hash = "sha256-GwuFtBVj0Z2rHryst/7cegskvZIMPsrAH12+K942+JA=";
          name = "atomize-atom-one-dark-theme";
          publisher = "emroussel";
        };

        meta = {
          description = "Detailed and accurate Atom One Dark theme for VSCode";
          homepage = "https://github.com/emroussel/atomize/blob/main/README.md";
          changelog = "https://marketplace.visualstudio.com/items/emroussel.atomize-atom-one-dark-theme/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=emroussel.atomize-atom-one-dark-theme";
        };
      };

      enkia.tokyo-night = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.2";
          hash = "sha256-oW0bkLKimpcjzxTb/yjShagjyVTUFEg198oPbY5J2hM=";
          name = "tokyo-night";
          publisher = "enkia";
        };

        meta = {
          description = "Clean Visual Studio Code theme that celebrates the lights of Downtown Tokyo at night";
          homepage = "https://github.com/enkia/tokyo-night-vscode-theme";
          changelog = "https://marketplace.visualstudio.com/items/enkia.tokyo-night/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=enkia.tokyo-night";
        };
      };

      esbenp.prettier-vscode = callPackage ./esbenp.prettier-vscode { };

      ethansk.restore-terminals = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.8";
          hash = "sha256-pZK/QNomQoFRsL6LRIKvWQj8/SYo2ZdVU47Gsmb9MXo=";
          name = "restore-terminals";
          publisher = "ethansk";
        };
      };

      eugleo.magic-racket = callPackage ./eugleo.magic-racket { };

      fabiospampinato.vscode-open-in-github = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.4.0";
          hash = "sha256-7jHU8sW6nBVumry3DjgM+CNOvm/oZCGBMzrat4lRAtg=";
          name = "vscode-open-in-github";
          publisher = "fabiospampinato";
        };

        meta = {
          description = "VS Code extension to open the current project or file in github.com";
          homepage = "https://github.com/fabiospampinato/vscode-open-in-github";
          changelog = "https://marketplace.visualstudio.com/items/fabiospampinato.vscode-open-in-github/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=fabiospampinato.vscode-open-in-github";
        };
      };

      file-icons.file-icons = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.0";
          name = "file-icons";
          publisher = "file-icons";
          sha256 = "sha256-vtYERwOvWqJ0NifeSBTn+jzwJTDmMPRyHbPq6I1lW0w=";
        };

        meta = {
          description = "File-specific icons in VSCode for improved visual grepping";
          homepage = "https://github.com/file-icons/vscode";
          changelog = "https://marketplace.visualstudio.com/items/file-icons.file-icons/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=file-icons.file-icons";
        };
      };

      fill-labs.dependi = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.7.25";
          hash = "sha256-DvLksbhruNHIav2EOCxajhqJC7sYsveUnCyPVLABj0Y=";
          name = "dependi";
          publisher = "fill-labs";
        };

        meta = {
          description = "VSCode extension for managing dependencies and address vulnerabilities in Rust, Go, JavaScript, and Python projects";
          homepage = "https://github.com/filllabs/dependi";
          changelog = "https://marketplace.visualstudio.com/items/fill-labs.dependi/changelog";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers._21CSM ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=fill-labs.dependi";
        };
      };

      firefox-devtools.vscode-firefox-debug = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.15.0";
          hash = "sha256-hBj0V42k32dj2gvsNStUBNZEG7iRYxeDMbuA15AYQqk=";
          name = "vscode-firefox-debug";
          publisher = "firefox-devtools";
        };

        meta = {
          description = "Visual Studio Code extension for debugging web applications and browser extensions in Firefox";
          homepage = "https://github.com/firefox-devtools/vscode-firefox-debug";
          changelog = "https://marketplace.visualstudio.com/items/firefox-devtools.vscode-firefox-debug/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.felschr ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=firefox-devtools.vscode-firefox-debug";
        };
      };

      firsttris.vscode-jest-runner = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.4.148";
          hash = "sha256-bqyi1uk4Y1PMOjVv+io3WxJMrJb7UKy368xt6TiySPg=";
          name = "vscode-jest-runner";
          publisher = "firsttris";
        };

        meta = {
          description = "Simple way to run or debug a single (or multiple) tests from context-menu";
          homepage = "https://github.com/firsttris/vscode-jest-runner";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=firsttris.vscode-jest-runner";
        };
      };

      foam.foam-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.44.1";
          hash = "sha256-OH4i4cGh/ivHQNAI55FHjM9ZjnhMaJSnsuQUnxub9/g=";
          name = "foam-vscode";
          publisher = "foam";
        };

        meta = {
          description = "Personal knowledge management and sharing system for VSCode ";
          homepage = "https://foambubble.github.io/";
          changelog = "https://marketplace.visualstudio.com/items/foam.foam-vscode/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.ratsclub ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=foam.foam-vscode";
        };
      };

      formulahendry.auto-close-tag = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.5.15";
          hash = "sha256-8lRdNGa7Shhmko8lhKxexNj4mkGEwPihBrsQrm5a1kA=";
          name = "auto-close-tag";
          publisher = "formulahendry";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      formulahendry.auto-rename-tag = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.10";
          hash = "sha256-uXqWebxnDwaUVLFG6MUh4bZ7jw5d2rTHRm5NoR2n0Vs=";
          name = "auto-rename-tag";
          publisher = "formulahendry";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      formulahendry.code-runner = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.12.2";
          hash = "sha256-TI5K6n3QfJwgFz5xhpdZ+yzi9VuYGcSzdBckZ68DsUQ=";
          name = "code-runner";
          publisher = "formulahendry";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      fortran-lang.linter-gfortran = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "4.0.0";
          hash = "sha256-T9vhLrCMOmoXsVW9O/siwA/eAZagZoKsvinpWgIuAE0=";
          name = "linter-gfortran";
          publisher = "fortran-lang";
        };

        meta = {
          description = "Fortran language support for Visual Studio Code";
          homepage = "https://github.com/fortran-lang/vscode-fortran-support";
          changelog = "https://marketplace.visualstudio.com/items/fortran-lang.linter-gfortran/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=fortran-lang.linter-gfortran";
        };
      };

      foxundermoon.shell-format = callPackage ./foxundermoon.shell-format { };

      freebroccolo.reasonml = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.38";
          name = "reasonml";
          publisher = "freebroccolo";
          sha256 = "1nay6qs9vcxd85ra4bv93gg3aqg3r2wmcnqmcsy9n8pg1ds1vngd";
        };

        meta = {
          description = "Reason support for Visual Studio Code";
          homepage = "https://github.com/reasonml-editor/vscode-reasonml";
          changelog = "https://marketplace.visualstudio.com/items/freebroccolo.reasonml/changelog";
          license = lib.licenses.asl20;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=freebroccolo.reasonml";
        };
      };

      fstarlang.fstar-vscode-assistant = callPackage ./fstarlang.fstar-vscode-assistant { };

      funkyremi.vscode-google-translate = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.5.0";
          hash = "sha256-t6USs2mZE3g802BRwP56eH/Wj/cyAcA+h/V+++NtHnA=";
          name = "vscode-google-translate";
          publisher = "funkyremi";
        };

        meta = {
          description = "Visual Studio Code extension using google translation to helping you quickly translate text right in your code rocket";
          homepage = "https://github.com/funkyremi/vscode-google-translate.git";
          changelog = "https://marketplace.visualstudio.com/items/funkyremi.vscode-google-translate/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ onedragon ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=funkyremi.vscode-google-translate";
        };
      };

      garlicbreadcleric.pandoc-markdown-syntax = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.2";
          hash = "sha256-YAMH5smLyBuoTdlxSCTPyMIKOWTSIdf2MQVZuOO2V1w=";
          name = "pandoc-markdown-syntax";
          publisher = "garlicbreadcleric";
        };

        meta = {
          description = "VSCode extension that adds syntax highlighting for Pandoc-flavored Markdown";
          homepage = "https://github.com/garlicbreadcleric/vscode-pandoc-markdown";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.pandapip1 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=garlicbreadcleric.pandoc-markdown-syntax";
        };
      };

      geequlim.godot-tools = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.7.1";
          hash = "sha256-TNCMSmZdBXxAHkcFLpTDkCzaXNO4yvkCfQ8Xrb9gquo=";
          name = "godot-tools";
          publisher = "geequlim";
        };

        meta = {
          description = "VS Code extension for game development with Godot Engine and GDScript";
          homepage = "https://github.com/godotengine/godot-vscode-plugin";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ thtrf ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools";
        };
      };

      gencer.html-slim-scss-css-class-completion = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.7.8";
          name = "html-slim-scss-css-class-completion";
          publisher = "gencer";
          sha256 = "18qws35qvnl0ahk5sxh4mzkw0ib788y1l97ijmpjszs0cd4bfsa6";
        };

        meta = {
          description = "VSCode extension for SCSS";
          homepage = "https://github.com/gencer/SCSS-Everywhere";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=gencer.html-slim-scss-css-class-completion";
        };
      };

      genieai.chatgpt-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.13";
          name = "chatgpt-vscode";
          publisher = "genieai";
          sha256 = "sha256-aoVICzU5sfA96FCU4ysUGmULruGWLaVo2lFpiPhdtGA=";
        };

        meta = {
          description = "Visual Studio Code extension to support ChatGPT, GPT-3 and Codex conversations";
          homepage = "https://github.com/ai-genie/chatgpt-vscode";
          changelog = "https://marketplace.visualstudio.com/items/genieai.chatgpt-vscode/changelog";
          license = lib.licenses.isc;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=genieai.chatgpt-vscode";
        };
      };

      ginfuru.better-solarized = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.10.9";
          hash = "sha256-Zh3u1iq/kSzwtOY1RmG4cwvN6nJO6ys88BXn/EH/wTs=";
          name = "ginfuru-better-solarized-dark-theme";
          publisher = "ginfuru";
        };

        meta = {
          description = "A Better Solarized theme for Visual Studio Code include light and dark versions";
          homepage = "https://github.com/ginfuru/vscode-better-solarized";
          changelog = "https://marketplace.visualstudio.com/items/ginfuru.ginfuru-better-solarized-dark-theme/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ginfuru.ginfuru-better-solarized-dark-theme";
        };
      };

      github.codespaces = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.18.15";
          hash = "sha256-NcW2XVQ6F7s6k4mIesEXhCkVVRfudwFr3glqB+TjrqM=";
          name = "codespaces";
          publisher = "github";
        };

        meta = {
          description = "VSCode extensions that provides cloud-hosted development environments for any activity";
          homepage = "https://github.com/features/codespaces";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers.therobot2105 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=GitHub.codespaces";
        };
      };

      github.copilot = callPackage ./github.copilot { };
      github.copilot-chat = callPackage ./github.copilot-chat { };

      github.github-vscode-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "6.3.5";
          hash = "sha256-dOadoYBPcYrpzmqOpJwG+/nPwTfJtlsOFDU3FctdR0o=";
          name = "github-vscode-theme";
          publisher = "github";
        };

        meta = {
          description = "GitHub theme for VS Code";
          homepage = "https://github.com/primer/github-vscode-theme";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.hugolgst ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=GitHub.github-vscode-theme";
        };
      };

      github.vscode-github-actions = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.31.5";
          hash = "sha256-hGdcMAkzpJqX61Ki87ckFAhncOm6LmNCQh4imIg64oY=";
          name = "vscode-github-actions";
          publisher = "github";
        };

        meta = {
          description = "Visual Studio Code extension for GitHub Actions workflows and runs for github.com hosted repositories";
          homepage = "https://github.com/github/vscode-github-actions";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=github.vscode-github-actions";
        };
      };

      github.vscode-pull-request-github = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.138.0";
          hash = "sha256-tOqBBgA6HxBc5TT4/A3OWKxDvaoqw8zXCtMa+K3Ku1E=";
          name = "vscode-pull-request-github";
          publisher = "github";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      gitlab.gitlab-workflow = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "6.84.2";
          hash = "sha256-UBoZ6DxT5d7zeTycgmuLomzoVcB7iAnflfxAup6QslI=";
          name = "gitlab-workflow";
          publisher = "gitlab";
        };

        meta = {
          description = "GitLab extension for Visual Studio Code";
          homepage = "https://gitlab.com/gitlab-org/gitlab-vscode-extension#readme";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=gitlab.gitlab-workflow";
        };
      };

      gleam.gleam = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.13.0";
          hash = "sha256-eCiBbdKMeXcRS4kyI2rH1iAT0CmQmo2SybeW+Y7FRio=";
          name = "gleam";
          publisher = "gleam";
        };

        meta = {
          description = "Support for the Gleam programming language";
          homepage = "https://github.com/gleam-lang/vscode-gleam#readme";
          license = lib.licenses.asl20;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Gleam.gleam";
        };
      };

      golang.go = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.54.0";
          hash = "sha256-o1SJjR6eQcGWN9BGoN5CBTdn6RsNG2a0+p/ZDcywzr0=";
          name = "Go";
          publisher = "golang";
        };

        meta = {
          description = "Go extension for Visual Studio Code";
          homepage = "https://github.com/golang/vscode-go";
          changelog = "https://marketplace.visualstudio.com/items/golang.Go/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=golang.Go";
        };
      };

      google.colab = callPackage ./google.colab { };
      gplane.wasm-language-tools = callPackage ./gplane.wasm-language-tools { };

      grafana.grafana-alloy = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.0";
          hash = "sha256-XcoiEDCPp6GzYQDhJArZBEWxSnZrSTHofIyLFegsbh0=";
          name = "grafana-alloy";
          publisher = "grafana";
        };

        meta = {
          description = "Grafana Alloy support for VSCode";
          changelog = "https://github.com/grafana/vscode-alloy/releases";
          license = lib.licenses.asl20;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=grafana.grafana-alloy";
        };
      };

      grapecity.gc-excelviewer = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "4.2.66";
          hash = "sha256-EFy5GjkgV5puELTzNat+30WC224PLDQJmJeBILc1Fvo=";
          name = "gc-excelviewer";
          publisher = "grapecity";
        };

        meta = {
          description = "Edit Excel spreadsheets and CSV files in Visual Studio Code and VS Code for the Web";
          homepage = "https://github.com/jjuback/gc-excelviewer";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.kamadorueda ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=grapecity.gc-excelviewer";
        };
      };

      graphql.vscode-graphql = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.13.4";
          hash = "sha256-zPc+jNbXfuXMWXxbKhaOpjgDu96jg5C+CCQ3HXEQ7fw=";
          name = "vscode-graphql";
          publisher = "GraphQL";
        };

        meta = {
          description = "GraphQL extension for VSCode built with the aim to tightly integrate the GraphQL Ecosystem with VSCode for an awesome developer experience";
          homepage = "https://github.com/graphql/graphiql/tree/main/packages/vscode-graphql";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=GraphQL.vscode-graphql";
        };
      };

      graphql.vscode-graphql-syntax = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.3.10";
          hash = "sha256-EY6BHl5ICcs3FuuenoadDXLLPSe8+2VAAydqo/YrtaE=";
          name = "vscode-graphql-syntax";
          publisher = "GraphQL";
        };

        meta = {
          description = "Adds full GraphQL syntax highlighting and language support such as bracket matching";
          homepage = "https://github.com/graphql/graphiql/tree/main/packages/vscode-graphql-syntax";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=GraphQL.vscode-graphql-syntax";
        };
      };

      griimick.vhs = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.4";
          hash = "sha256-zAy8o5d2pK5ra/dbwoLgPAQAYfRQtUYQjisWYgIhsXA=";
          name = "vhs";
          publisher = "griimick";
        };

        meta = {
          description = "Visual Studio Code extension providing syntax support for VHS .tape files";
          homepage = "https://github.com/griimick/vscode-vhs";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=griimick.vhs";
        };
      };

      gruntfuggly.todo-tree = callPackage ./gruntfuggly.todo-tree { };

      hars.cppsnippets = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.15";
          hash = "sha256-KXdEKcxPclbD22aKGAKSmdpVBZP2IpQRaKfc2LDsL0U=";
          name = "cppsnippets";
          publisher = "hars";
        };

        meta = {
          description = "Code snippets for C/C++";
          homepage = "https://github.com/one-harsh/vscode-cpp-snippets";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=hars.CppSnippets";
        };
      };

      hashicorp.hcl = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.6.0";
          hash = "sha256-Za2ODrsHR/y0X/FOhVEtbg6bNs439G6rlBHW84EZS60=";
          name = "HCL";
          publisher = "HashiCorp";
        };

        meta = {
          description = "HashiCorp HCL syntax";
          homepage = "https://github.com/hashicorp/vscode-hcl";
          license = lib.licenses.mpl20;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=HashiCorp.HCL";
        };
      };

      hashicorp.terraform = callPackage ./hashicorp.terraform { };

      haskell.haskell = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.8.1";
          hash = "sha256-mAlEy5a83BRhUhA22AKheP6PPpfbrdGT6HsTKbFwJYs=";
          name = "haskell";
          publisher = "haskell";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      hbenl.vscode-test-explorer = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.22.1";
          hash = "sha256-+vW/ZpOQXI7rDUAdWfNOb2sAGQQEolXjSMl2tc/Of8M=";
          name = "vscode-test-explorer";
          publisher = "hbenl";
        };

        meta = {
          description = "Visual Studio Code extension that runs your tests in the sidebar";
          homepage = "https://github.com/hbenl/vscode-test-explorer";
          changelog = "https://github.com/hbenl/vscode-test-explorer/blob/master/CHANGELOG.md";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=hbenl.vscode-test-explorer";
        };
      };

      hediet.vscode-drawio = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.9.0";
          hash = "sha256-gi3+mMJcUnkb0FFb6gmx9eI8BRLX3z/kTr7Rk0hudP4=";
          name = "vscode-drawio";
          publisher = "hediet";
        };

        meta = {
          description = "This unofficial extension integrates Draw.io into VS Code";
          homepage = "https://github.com/hediet/vscode-drawio";
          license = lib.licenses.gpl3Only;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=hediet.vscode-drawio";
        };
      };

      hirse.vscode-ungit = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.5.2";
          hash = "sha256-0CFYL6rBecB8rNnk4IAtg03ZPdSJ9qxwnVdhdQedxsQ=";
          name = "vscode-ungit";
          publisher = "hirse";
        };

        meta = {
          description = "Ungit in Visual Studio Code";
          homepage = "https://github.com/hirse/vscode-ungit";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.therobot2105 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Hirse.vscode-ungit";
        };
      };

      hiukky.flate = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.7.0";
          hash = "sha256-6ouYQk7mHCJdGrcutM1EXolJAT7/Sp1hi+Bu0983GKw=";
          name = "flate";
          publisher = "hiukky";
        };

        meta = {
          description = "Colorful dark themes for VS Code";
          homepage = "https://github.com/hiukky/flate";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.stunkymonkey ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=hiukky.flate";
        };
      };

      hookyqr.beautify = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.5.0";
          name = "beautify";
          publisher = "HookyQR";
          sha256 = "1c0kfavdwgwham92xrh0gnyxkrl9qlkpv39l1yhrldn8vd10fj5i";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      huacnlee.autocorrect = callPackage ./huacnlee.autocorrect { };

      humao.rest-client = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.25.1";
          hash = "sha256-DSzZ9wGB0IVK8gYOzLLbT03WX3xSmR/IUVZkDzcczKc=";
          name = "rest-client";
          publisher = "humao";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      huytd.nord-light = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.1";
          hash = "sha256-q2GG3j5j3CLGF02J7/plywKLkhUmm2Gn3MiSVmiZ+48=";
          name = "nord-light";
          publisher = "huytd";
        };

        meta = {
          description = "Light theme for VSCode based on the Nord color palette";
          homepage = "https://github.com/huytd/vscode-nord-light";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.Flameopathic ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=huytd.nord-light";
        };
      };

      ibm.output-colorizer = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.2";
          name = "output-colorizer";
          publisher = "IBM";
          sha256 = "0i9kpnlk3naycc7k8gmcxas3s06d67wxr3nnyv5hxmsnsx5sfvb7";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      iciclesoft.workspacesort = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.6.2";
          hash = "sha256-ZsjBgoTr4LGQW0kn+CtbdLwpPHmlYl5LKhwXIzcPe2o=";
          name = "workspacesort";
          publisher = "iciclesoft";
        };

        meta = {
          description = "Sort workspace-folders alphabetically rather than in chronological order";
          homepage = "https://github.com/iciclesoft/workspacesort-for-VSCode";
          changelog = "https://marketplace.visualstudio.com/items/iciclesoft.workspacesort/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.dbirks ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=iciclesoft.workspacesort";
        };
      };

      iliazeus.vscode-ansi = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.7";
          hash = "sha256-3/rsYq+HZgRW2Vd91ZW9rkXWUTUFzG/mCWD0pm++WA4=";
          name = "vscode-ansi";
          publisher = "iliazeus";
        };

        meta = {
          description = "ANSI color styling for text documents";
          homepage = "https://github.com/iliazeus/vscode-ansi";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=iliazeus.vscode-ansi";
        };
      };

      illixion.vscode-vibrancy-continued = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.84";
          hash = "sha256-NijfD83LfEAsYsZtKwj/sBVqzpXht6pvtVZCQUUdfq0=";
          name = "vscode-vibrancy-continued";
          publisher = "illixion";
        };

        meta = {
          description = "Vibrancy Effect for Visual Studio Code";
          homepage = "https://github.com/illixion/vscode-vibrancy-continued#readme";
          changelog = "https://marketplace.visualstudio.com/items/illixion.vscode-vibrancy-continued/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ _2hexed ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=illixion.vscode-vibrancy-continued";
        };
      };

      intellsmi.comment-translate = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.1.0";
          hash = "sha256-hn3G2arNr3LWMOeMLkRdR/GTWobeczaIzGI59x9/oK8=";
          name = "comment-translate";
          publisher = "intellsmi";
        };

        meta = {
          description = "Visual Studio Code extension to translate the comments for computer language";

          longDescription = ''
            This plugin uses the Google Translate API to translate comments for the VSCode programming language.
          '';

          homepage = "https://github.com/intellism/vscode-comment-translate/blob/HEAD/doc/README.md";
          changelog = "https://marketplace.visualstudio.com/items/intellsmi.comment-translate/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ onedragon ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=intellsmi.comment-translate";
        };
      };

      ionic.ionic = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.105.0";
          hash = "sha256-wUYX7TmCyzKGPnl7LycfxN5axCGzq/T2/+XnSdPJJEI=";
          name = "ionic";
          publisher = "ionic";
        };

        meta = {
          description = "Official VSCode extension for Ionic and Capacitor development";
          homepage = "https://github.com/ionic-team/vscode-ionic";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ thtrf ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ionic.ionic";
        };
      };

      ionide.ionide-fsharp = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "7.31.1";
          hash = "sha256-phVmMpcg3t08IeUgEOzdFPhW9Z/4XjbzmM9j17ra+uo=";
          name = "Ionide-fsharp";
          publisher = "Ionide";
        };

        meta = {
          description = "Enhanced F# Language Features for Visual Studio Code";
          homepage = "https://ionide.io";
          changelog = "https://marketplace.visualstudio.com/items/Ionide.Ionide-fsharp/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.ratsclub ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Ionide.Ionide-fsharp";
        };
      };

      irongeek.vscode-env = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.0";
          hash = "sha256-URq90lOFtPCNfSIl2NUwihwRQyqgDysGmBc3NG7o7vk=";
          name = "vscode-env";
          publisher = "irongeek";
        };

        meta = {
          description = "Adds formatting and syntax highlighting support for env files (.env) to Visual Studio Code";
          homepage = "https://github.com/IronGeek/vscode-env.git";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=IronGeek.vscode-env";
        };
      };

      jackmacwindows.craftos-pc = callPackage ./jackmacwindows.craftos-pc { };

      jackmacwindows.vscode-computercraft = buildVscodeMarketplaceExtension {
        postInstall = ''
          # Remove superflouous images to reduce closure size
          rm $out/$installPrefix/images/*.gif
        '';

        mktplcRef = {
          version = "1.1.1";
          hash = "sha256-ec1I3oQ06iMdSUcqf8yA3GjE7Aqa0PiLzRQLwFcL0KU=";
          name = "vscode-computercraft";
          publisher = "jackmacwindows";
        };

        meta = {
          description = "Visual Studio Code extension for ComputerCraft and CC: Tweaked auto-completion";
          homepage = "https://github.com/MCJack123/vscode-computercraft";
          changelog = "https://marketplace.visualstudio.com/items/jackmacwindows.vscode-computercraft/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ tomodachi94 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jackmacwindows.vscode-computercraft";
        };
      };

      jakestanger.corn = callPackage ./jakestanger.corn { };
      james-yu.latex-workshop = callPackage ./james-yu.latex-workshop { };

      jamesyang999.vscode-emacs-minimum = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.1";
          hash = "sha256-qxnAhT2UGTQmPw9XmdBdx0F0NNLAaU1/ES9jiqiRrGI=";
          name = "vscode-emacs-minimum";
          publisher = "jamesyang999";
        };

        meta = {
          description = "Minimal emacs key bindings for VSCode";
          homepage = "https://github.com/futurist/vscode-emacs-minimum";
          license = lib.licenses.unfree;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jamesyang999.vscode-emacs-minimum";
        };
      };

      janet-lang.vscode-janet = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.2";
          hash = "sha256-oj0e++z2BtadIXOnTlocIIHliYweZ1iyrV08DwatfLI=";
          name = "vscode-janet";
          publisher = "janet-lang";
        };

        meta = {
          description = "Janet language support for Visual Studio Code";
          homepage = "https://github.com/janet-lang/vscode-janet";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=janet-lang.vscode-janet";
        };
      };

      jasew.anki = callPackage ./jasew.anki { };

      jbockle.jbockle-format-files = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.4.0";
          hash = "sha256-BHw+T2EPdQq/wOD5kzvSln5SBFTYUXip8QDjnAGBfFY=";
          name = "jbockle-format-files";
          publisher = "jbockle";
        };

        meta = {
          description = "VSCode extension to formats all files in the current workspace";
          homepage = "https://github.com/jbockle/format-files";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jbockle.jbockle-format-files";
        };
      };

      jdinhlife.gruvbox = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.29.1";
          hash = "sha256-FGZx/R3hLgYlC2BdQkcJ+puQtgNYm2iPbJJJmjEzLS0=";
          name = "gruvbox";
          publisher = "jdinhlife";
        };

        meta = {
          description = "Port of Gruvbox theme to VS Code editor";
          homepage = "https://github.com/jdinhify/vscode-theme-gruvbox";
          changelog = "https://marketplace.visualstudio.com/items/jdinhlife.gruvbox/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.imgabe ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jdinhlife.gruvbox";
        };
      };

      jebbs.plantuml = callPackage ./jebbs.plantuml { };

      jeff-hykin.better-nix-syntax = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.3.0";
          hash = "sha256-Zb4RFs2qkSMeQKkNXk4brrZBDiRK4e08taOOgdRWQEk=";
          name = "better-nix-syntax";
          publisher = "jeff-hykin";
        };

        meta = {
          description = "Visual Studio Code extension providing Nix Syntax highlighting";
          homepage = "https://github.com/jeff-hykin/better-nix-syntax";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jeff-hykin.better-nix-syntax";
        };
      };

      jellyedwards.gitsweep = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.0";
          hash = "sha256-XBD8rN6E/0GjZ3zXgR45MN9v4PYrEXBSzN7+CcLrRsg=";
          name = "gitsweep";
          publisher = "jellyedwards";
        };

        meta = {
          description = "VS Code extension which allows you to easily exclude modified or new files so they don't get committed accidentally";
          homepage = "https://github.com/jellyedwards/gitsweep";
          changelog = "https://marketplace.visualstudio.com/items/jellyedwards.gitsweep/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.MatthieuBarthel ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jellyedwards.gitsweep";
        };
      };

      jetmartin.bats = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.10";
          hash = "sha256-WD1YTRgzSVElixnNGtg6mMlcLCIaI6IBb+uh4cfzuBs=";
          name = "bats";
          publisher = "jetmartin";
        };

        meta = {
          description = "VSCode extension for full language support for the Bats (Bash Automated Testing System) testing framework";
          homepage = "https://github.com/bats-core/bats-vscode";
          changelog = "https://marketplace.visualstudio.com/items/jetmartin.bats/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.dotmobo ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jetmartin.bats";
        };
      };

      jgclark.vscode-todo-highlight = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.0.8";
          hash = "sha256-/CctaLcG+dA2Cf69/ACeDKdRLsu/VUGbAxUbyhI0VyA=";
          name = "vscode-todo-highlight";
          publisher = "jgclark";
        };

        meta = {
          description = "Highlight TODOs, FIXMEs, and any keywords, annotations...";
          homepage = "https://github.com/jgclark/vscode-todo-highlight";
          changelog = "https://marketplace.visualstudio.com/items/wayou.vscode-todo-highlight/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jgclark.vscode-todo-highlight";
        };
      };

      jjk.jjk = callPackage ./jjk.jjk { };

      jkillian.custom-local-formatters = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.1";
          hash = "sha256-Yxui136wK+C5d0h79nXpGQ+lEclmne8XNNxDgUEG6kM=";
          name = "custom-local-formatters";
          publisher = "jkillian";
        };

        meta = {
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.kamadorueda ];
        };
      };

      jnoortheen.nix-ide = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.5.9";
          hash = "sha256-hPOcp6Yksgfu1+In21/gJ3MthV8JUV5WaRpYHvo5GGk=";
          name = "nix-ide";
          publisher = "jnoortheen";
        };

        meta = {
          description = "Nix language support with formatting and error report";
          homepage = "https://github.com/nix-community/vscode-nix-ide";
          changelog = "https://marketplace.visualstudio.com/items/jnoortheen.nix-ide/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jnoortheen.nix-ide";
        };
      };

      jock.svg = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.5.4";
          hash = "sha256-LZLKUmYSnlgypLXKFOGezMepV10t35unpEnCMaLRjeU=";
          name = "svg";
          publisher = "jock";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      johnpapa.vscode-peacock = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "4.2.3";
          name = "vscode-peacock";
          publisher = "johnpapa";
          sha256 = "sha256-SVjuWjvQogtT74QRDxGJVvlXU035VMWtLiDz395URRE=";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      johnpapa.winteriscoming = callPackage ./johnpapa.winteriscoming { };
      joshmu.periscope = callPackage ./joshmu.periscope { };

      jroesch.lean = buildVscodeMarketplaceExtension rec {
        mktplcRef = {
          version = "0.16.60";
          hash = "sha256-z0mOnbqpKMH5d78jAMgDIgO+5sk4xHOWAfa4kzXYISs=";
          name = "lean";
          publisher = "jroesch";
        };

        meta = {
          description = "Lean 3 language support for VS Code";
          homepage = "https://github.com/leanprover/vscode-lean";
          changelog = "https://github.com/leanprover/vscode-lean/blob/v${mktplcRef.version}/README.md#release-notes";
          license = lib.licenses.asl20;
          maintainers = with lib.maintainers; [ dotlambda ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=jroesch.lean";
        };
      };

      julialang.language-julia = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.219.2";
          hash = "sha256-LQ7UL+/FtzRxn/M85fv3oh8g622KEPS35lque3kqby8=";
          name = "language-julia";
          publisher = "julialang";
        };

        meta = {
          description = "Visual Studio Code extension for Julia programming language";
          homepage = "https://github.com/julia-vscode/julia-vscode";
          changelog = "https://marketplace.visualstudio.com/items/julialang.language-julia/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=julialang.language-julia";
        };
      };

      justusadam.language-haskell = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.6.0";
          hash = "sha256-rZXRzPmu7IYmyRWANtpJp3wp0r/RwB7eGHEJa7hBvoQ=";
          name = "language-haskell";
          publisher = "justusadam";
        };

        meta = {
          license = lib.licenses.bsd3;
        };
      };

      k--kato.intellij-idea-keybindings = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.7.7";
          hash = "sha256-+XF+Odb9nMKclQkB/lwFuVpCHlVq6LNG/gQATVBcrYc=";
          name = "intellij-idea-keybindings";
          publisher = "k--kato";
        };

        meta = {
          description = "Visual Studio Code extension for IntelliJ IDEA keybindings";
          homepage = "https://github.com/kasecato/vscode-intellij-idea-keybindings";
          changelog = "https://marketplace.visualstudio.com/items/k--kato.intellij-idea-keybindings/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.t4sm5n ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=k--kato.intellij-idea-keybindings";
        };
      };

      kahole.magit = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.6.69";
          hash = "sha256-gx7OWV+X17XqShFj0mH4Zg6X26vpOnkrYW8/YdeGd7c=";
          name = "magit";
          publisher = "kahole";
        };

        meta = {
          description = "Magit for VSCode";
          homepage = "https://github.com/kahole/edamagit";
          changelog = "https://marketplace.visualstudio.com/items/kahole.magit/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.azd325 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=kahole.magit";
        };
      };

      kalebpace.balena-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.3";
          hash = "sha256-CecEv19nEtnMe0KlCMNBM9ZAjbAVgPNUcZ6cBxHw44M=";
          name = "balena-vscode";
          publisher = "kalebpace";
        };

        meta = {
          description = "VS Code extension for integration with Balena";
          homepage = "https://github.com/balena-vscode/balena-vscode";
          changelog = "https://marketplace.visualstudio.com/items/kalebpace.balena-vscode/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.kalebpace ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=kalebpace.balena-vscode";
        };
      };

      kamadorueda.alejandra = callPackage ./kamadorueda.alejandra { };

      kamikillerto.vscode-colorize = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.17.1";
          name = "vscode-colorize";
          publisher = "kamikillerto";
          sha256 = "sha256-JygJj2oZSOqklwfqMr+zwOYmaDp+3mh+jWMNOx6ccms=";
        };

        meta = {
          license = lib.licenses.asl20;
        };
      };

      karunamurti.haml = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.4.1";
          name = "haml";
          publisher = "karunamurti";
          sha256 = "123cwfajakkg2pr0z4v289fzzlhwbxx9dvb5bjc32l3pzvbhq4gv";
        };

        meta.license = lib.licenses.mit;
      };

      kddejong.vscode-cfn-lint =
        let
          inherit (python3Packages) cfn-lint pydot;
        in
        buildVscodeMarketplaceExtension {
          nativeBuildInputs = [
            jq
            moreutils
          ];

          buildInputs = [
            cfn-lint
            pydot
          ];

          postInstall = ''
            cd "$out/$installPrefix"
            jq '.contributes.configuration.properties."cfnLint.path".default = "${cfn-lint}/bin/cfn-lint"' package.json | sponge package.json
          '';

          mktplcRef = {
            version = "0.26.6";
            hash = "sha256-83hvz4nqpOxou5tFmiXyuUgWjRnTrOu42R+pRJdNbwU=";
            name = "vscode-cfn-lint";
            publisher = "kddejong";
          };

          meta = {
            description = "CloudFormation Linter IDE integration, autocompletion, and documentation";
            homepage = "https://github.com/aws-cloudformation/cfn-lint-visual-studio-code";
            license = lib.licenses.asl20;
            maintainers = [ ];
          };
        };

      kilocode.kilo-code = callPackage ./kilocode.kilo-code { };

      kravets.vscode-publint = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.0";
          hash = "sha256-GfIbQajdBpC0i8x7YlKYgpBwweWop4OBUU7dIDi9Yvk=";
          name = "vscode-publint";
          publisher = "Kravets";
        };

        meta = {
          description = "Lint packaging errors in VS Code with publint";
          homepage = "https://github.com/kravetsone/vscode-publint";
          changelog = "https://marketplace.visualstudio.com/items/Kravets.vscode-publint/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Kravets.vscode-publint";
        };
      };

      kubukoz.nickel-syntax = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.2";
          hash = "sha256-ffPZd717Y2OF4d9MWE6zKwcsGWS90ZJvhWkqP831tVM=";
          name = "nickel-syntax";
          publisher = "kubukoz";
        };

        meta = {
          license = lib.licenses.asl20;
        };
      };

      lapo.asn1js = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.2";
          hash = "sha256-U1mvxDqyNbTalKgxtCLxLOMT3ZxVGC2KXWW47khtQKA=";
          name = "asn1js";
          publisher = "lapo";
        };

        meta = {
          description = "Decode ASN.1 content inside VSCode";
          homepage = "https://github.com/lapo-luchini/vscode-asn1js";
          license = lib.licenses.isc;
          maintainers = with lib.maintainers; [ katexochen ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=lapo.asn1js";
        };
      };

      leanprover.lean4 = callPackage ./leanprover.lean4 { };

      leonardssh.vscord = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "5.3.9";
          hash = "sha256-DZlIlxFEI4h5304771yZgQt6FiNVCqgzlH2qe1B1Riw=";
          name = "vscord";
          publisher = "leonardssh";
        };

        meta = {
          description = "Highly customizable Discord Rich Presence extension for Visual Studio Code";
          homepage = "https://github.com/leonardssh/vscord";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.ryand56 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=leonardssh.vscord";
        };
      };

      llvm-org.lldb-vscode = llvmPackages.lldb;
      llvm-vs-code-extensions.lldb-dap = callPackage ./llvm-vs-code-extensions.lldb-dap { };

      llvm-vs-code-extensions.vscode-clangd = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.6.0";
          hash = "sha256-hmoAPCp0BKB3z6z2Ai0w45RDE9v3BYupmu2A5y5OM50=";
          name = "vscode-clangd";
          publisher = "llvm-vs-code-extensions";
        };

        meta = {
          description = "C/C++ completion, navigation, and insights";
          homepage = "https://github.com/clangd/vscode-clangd";
          changelog = "https://marketplace.visualstudio.com/items/llvm-vs-code-extensions.vscode-clangd/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=llvm-vs-code-extensions.vscode-clangd";
        };
      };

      lokalise.i18n-ally = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.13.1";
          hash = "sha256-Qraxg8FrMnBqbvR6ww3cJPFauY5zqe8P2hANqE1z95c=";
          name = "i18n-ally";
          publisher = "Lokalise";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ltex-plus.vscode-ltex-plus = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "15.7.1";
          hash = "sha256-wOwOD/rsUdwGJ24n6NkH1XY5Hf4T6LE34nFDOteubLY=";
          name = "vscode-ltex-plus";
          publisher = "ltex-plus";
        };

        meta = {
          description = "VS Code extension for grammar/spell checking using LanguageTool with support for LaTeX, Markdown, and others";
          homepage = "https://github.com/ltex-plus/vscode-ltex-plus";
          license = lib.licenses.mpl20;
          maintainers = with lib.maintainers; [ thtrf ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ltex-plus.vscode-ltex-plus";
        };
      };

      lucperkins.vrl-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.4";
          hash = "sha256-xcGa43iPwUR6spOJGTmmWA1dOMNMQEdiuhMZPYZ+dTU=";
          name = "vrl-vscode";
          publisher = "lucperkins";
        };

        meta = {
          description = "VS Code extension for Vector Remap Language (VRL)";
          homepage = "https://github.com/lucperkins/vrl-vscode";
          license = lib.licenses.mpl20;
          maintainers = [ lib.maintainers.lucperkins ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=lucperkins.vrl-vscode";
        };
      };

      mads-hartmann.bash-ide-vscode = callPackage ./mads-hartmann.bash-ide-vscode { };

      marp-team.marp-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.5.1";
          hash = "sha256-t8ozV99HBHLiVMYMxh8bJ2QzMd/2PEeEDpzvqHavwPw=";
          name = "marp-vscode";
          publisher = "marp-team";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      marus25.cortex-debug = callPackage ./marus25.cortex-debug { };

      matangover.mypy = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.4.2";
          hash = "sha256-T0H2JGr1WgSgXbf3aLvjKK0OOh9O+eg9YLs/ydblb9U=";
          name = "mypy";
          publisher = "matangover";
        };

        meta.license = lib.licenses.mit;
      };

      mathiasfrohlich.kotlin = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.7.1";
          hash = "sha256-MuAlX6cdYMLYRX2sLnaxWzdNPcZ4G0Fdf04fmnzQKH4=";
          name = "Kotlin";
          publisher = "mathiasfrohlich";
        };

        meta = {
          description = "Kotlin language support for VS Code";
          homepage = "https://github.com/mathiasfrohlich/vscode-kotlin";
          license = lib.licenses.asl20;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=mathiasfrohlich.Kotlin";
        };
      };

      matthewpi.caddyfile-support = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.4.0";
          hash = "sha256-J4O112VM3Ullyy39ZLw9ieBxVCJQ6yBxdiKtvXyOULo=";
          name = "caddyfile-support";
          publisher = "matthewpi";
        };

        meta = {
          description = "Rich Caddyfile support for Visual Studio Code";
          homepage = "https://github.com/caddyserver/vscode-caddyfile";
          changelog = "https://marketplace.visualstudio.com/items/matthewpi.caddyfile-support/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.matthewpi ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=matthewpi.caddyfile-support";
        };
      };

      mattn.lisp = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.12";
          hash = "sha256-x6aFrcX0YElEFEr0qA669/LPlab15npmXd5Q585pIEw=";
          name = "lisp";
          publisher = "mattn";
        };

        meta = {
          description = "Lisp syntax for vscode";
          homepage = "https://github.com/mattn/vscode-lisp";
          changelog = "https://marketplace.visualstudio.com/items/mattn.lisp/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.kamadorueda ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=mattn.lisp";
        };
      };

      maximedenes.vscoq = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.2.6";
          hash = "sha256-QBUTOFhdksHGkpYqgQIF2u+WodYH5PmMMvGFHwEEEIk=";
          name = "vscoq";
          publisher = "maximedenes";
        };

        meta = {
          description = "VsCoq is an extension for Visual Studio Code (VS Code) and VSCodium with support for the Coq Proof Assistant";
          homepage = "https://github.com/coq-community/vscoq";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.Zimmi48 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=maximedenes.vscoq";
        };
      };

      mechatroner.rainbow-csv = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.24.1";
          hash = "sha256-xZpK6pJNXnxudauzJihEi9VASRXi89+hn7vfF33qRgY=";
          name = "rainbow-csv";
          publisher = "mechatroner";
        };

        meta = {
          description = "Rainbow syntax higlighting for CSV and TSV files in Visual Studio Code";
          homepage = "https://github.com/mechatroner/vscode_rainbow_csv";
          changelog = "https://marketplace.visualstudio.com/items/mechatroner.rainbow-csv/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemname=mechatroner.rainbow-csv";
        };
      };

      meganrogge.template-string-converter = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.6.1";
          hash = "sha256-w0ppzh0m/9Hw3BPJbAKsNcMStdzoH9ODf3zweRcCG5k=";
          name = "template-string-converter";
          publisher = "meganrogge";
        };

        meta = {
          description = "VS Code extension to autocorrect from quotes to backticks";
          homepage = "https://github.com/meganrogge/template-string-converter";
          changelog = "https://marketplace.visualstudio.com/items/meganrogge.template-string-converter/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=meganrogge.template-string-converter";
        };
      };

      mesonbuild.mesonbuild = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.28.2";
          hash = "sha256-Wb3cfATe8pc+LftmKyFj3q6kmdTHUMtoIHlChKKeEoU=";
          name = "mesonbuild";
          publisher = "mesonbuild";
        };

        meta = {
          description = "Meson language support for Visual Studio Code";
          homepage = "https://github.com/mesonbuild/vscode-meson";
          changelog = "https://marketplace.visualstudio.com/items/mesonbuild.mesonbuild/changelog";
          license = lib.licenses.asl20;
          maintainers = with lib.maintainers; [ Anillc ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=mesonbuild.mesonbuild";
        };
      };

      mhutchie.git-graph = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.30.0";
          hash = "sha256-sHeaMMr5hmQ0kAFZxxMiRk6f0mfjkg2XMnA4Gf+DHwA=";
          name = "git-graph";
          publisher = "mhutchie";
        };

        meta = {
          license = lib.licenses.unfree;
        };
      };

      miguelsolorio.fluent-icons = callPackage ./miguelsolorio.fluent-icons { };
      miguelsolorio.min-theme = callPackage ./miguelsolorio.min-theme { };

      mikestead.dotenv = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.1";
          hash = "sha256-dieCzNOIcZiTGu4Mv5zYlG7jLhaEsJR05qbzzzQ7RWc=";
          name = "dotenv";
          publisher = "mikestead";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      mishkinf.goto-next-previous-member = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.10";
          name = "goto-next-previous-member";
          publisher = "mishkinf";
          sha256 = "sha256-mRPWEU/M5uhiDUl9KwQi6w5hfzIZxKMhO48ssVfICoQ=";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      mkhl.direnv = callPackage ./mkhl.direnv { };
      mkhl.shfmt = callPackage ./mkhl.shfmt { };
      mongodb.mongodb-vscode = callPackage ./mongodb.mongodb-vscode { };

      moshfeu.compare-folders = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.30.0";
          hash = "sha256-XBMHEk5iRW6n9fjDUbD8c/FFGNRttrnV0tH1qUphXYo=";
          name = "compare-folders";
          publisher = "moshfeu";
        };

        meta = {
          description = "Extension allows you to compare folders, show the diffs in a list and present diff in a splitted view side by side";
          homepage = "https://github.com/moshfeu/vscode-compare-folders";
          changelog = "https://github.com/moshfeu/vscode-compare-folders/releases";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=moshfeu.compare-folders";
        };
      };

      motivesoft.vscode-man-page-syntax = callPackage ./motivesoft.vscode-man-page-syntax { };
      ms-azuretools.vscode-bicep = callPackage ./ms-azuretools.vscode-bicep { };
      ms-azuretools.vscode-containers = callPackage ./ms-azuretools.vscode-containers { };

      ms-azuretools.vscode-docker = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.0.0";
          hash = "sha256-Yxysekp9nC91g7M5oXppOF+Rf4Jf/PD+X3inmdVfVmo=";
          name = "vscode-docker";
          publisher = "ms-azuretools";
        };

        meta = {
          description = "Docker Extension for Visual Studio Code";
          homepage = "https://github.com/microsoft/vscode-docker";
          changelog = "https://marketplace.visualstudio.com/items/ms-azuretools.vscode-docker/changelog";
          license = lib.licenses.mit;
        };
      };

      ms-ceintl = callPackage ./language-packs.nix { }; # non-English language packs
      ms-dotnettools.csdevkit = callPackage ./ms-dotnettools.csdevkit { };
      ms-dotnettools.csharp = callPackage ./ms-dotnettools.csharp { };

      ms-dotnettools.vscode-dotnet-runtime = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.1.0";
          hash = "sha256-jmdf/l82dEMNY+KNLcBatA82yElOlUnnnTmV1yGxP1o=";
          name = "vscode-dotnet-runtime";
          publisher = "ms-dotnettools";
        };

        meta = {
          description = "Provides a way for other Visual Studio Code extensions to install local versions of .NET SDK/Runtime";
          homepage = "https://github.com/dotnet/vscode-dotnet-runtime";
          changelog = "https://marketplace.visualstudio.com/items/ms-dotnettools.vscode-dotnet-runtime/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.magnouvean ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.vscode-dotnet-runtime";
        };
      };

      ms-dotnettools.vscodeintellicode-csharp = buildVscodeMarketplaceExtension {
        nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

        buildInputs = [
          (lib.getLib stdenv.cc.cc)
          zlib
        ];

        mktplcRef =
          let
            sources = {
              "aarch64-darwin" = {
                arch = "darwin-arm64";
                hash = "sha256-8XIeK5AIFKQaK5YMNSRqxr5p72zXb7ZLPq6PbeWO864=";
              };

              "aarch64-linux" = {
                arch = "linux-arm64";
                hash = "sha256-pnQP1OKr3NJgUuXzO1InYqGA49OuMFn2iEf8wpl4PqM=";
              };

              "x86_64-linux" = {
                arch = "linux-x64";
                hash = "sha256-pmA7BNwyHiaU93j61/MyrBV5kH0DlW+7BA6HNlKGnso=";
              };
            };
          in
          {
            version = "2.2.3";
            name = "vscodeintellicode-csharp";
            publisher = "ms-dotnettools";
          }
          // sources.${stdenv.system} or (throw "Unsupported system: ${stdenv.system}");

        meta = {
          description = "AI-assisted development features for C# in Visual Studio Code";
          homepage = "https://github.com/MicrosoftDocs/intellicode";
          changelog = "https://marketplace.visualstudio.com/items/ms-dotnettools.vscodeintellicode-csharp/changelog";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers.magnouvean ];

          platforms = [
            "x86_64-linux"
            "aarch64-darwin"
            "aarch64-linux"
          ];

          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-dotnettools.vscodeintellicode-csharp";
        };
      };

      ms-kubernetes-tools.vscode-kubernetes-tools = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.4.0";
          hash = "sha256-t64OF+rxTphnWr1BNUYxG0/W+gAP8dziARpQK8FIzU4=";
          name = "vscode-kubernetes-tools";
          publisher = "ms-kubernetes-tools";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ms-pyright.pyright = callPackage ./ms-pyright.pyright { };
      ms-python.black-formatter = callPackage ./ms-python.black-formatter { };
      ms-python.debugpy = callPackage ./ms-python.debugpy { };
      ms-python.flake8 = callPackage ./ms-python.flake8 { };
      ms-python.isort = callPackage ./ms-python.isort { };
      ms-python.mypy-type-checker = callPackage ./ms-python.mypy-type-checker { };
      ms-python.pylint = callPackage ./ms-python.pylint { };
      ms-python.python = callPackage ./ms-python.python { };
      ms-python.vscode-pylance = callPackage ./ms-python.vscode-pylance { };
      ms-python.vscode-python-envs = callPackage ./ms-python.vscode-python-envs { };

      ms-toolsai.datawrangler = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.24.0";
          hash = "sha256-FWzrxf5uaPcbu1JCiYxsbkju1mY3n3F2vGLvfMuZxlc=";
          name = "datawrangler";
          publisher = "ms-toolsai";
        };

        meta = {
          description = "Data viewing, cleaning and preparation for tabular datasets";
          homepage = "https://github.com/microsoft/vscode-data-wrangler";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers.katanallama ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-toolsai.datawrangler";
        };
      };

      ms-toolsai.jupyter = callPackage ./ms-toolsai.jupyter { };

      ms-toolsai.jupyter-keymap = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.2";
          hash = "sha256-9BLyBZzZ0Z6QQ05QSxFJYNZmZDc5O3eYkCxe/UsmKws=";
          name = "jupyter-keymap";
          publisher = "ms-toolsai";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ms-toolsai.jupyter-renderers = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.3.0";
          hash = "sha256-GBqHvXikCgLGW7Xm05Iq1xqs8j9H9k9c8iASsAjA87I=";
          name = "jupyter-renderers";
          publisher = "ms-toolsai";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ms-toolsai.vscode-jupyter-cell-tags = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.9";
          hash = "sha256-XODbFbOr2kBTzFc0JtjiDUcCDBX1Hd4uajlil7mhqPY=";
          name = "vscode-jupyter-cell-tags";
          publisher = "ms-toolsai";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ms-toolsai.vscode-jupyter-slideshow = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.6";
          hash = "sha256-fnsMrrcYdz6BzUWMd9pAOQGTjmtEbQeoVYG20VWxCsM=";
          name = "vscode-jupyter-slideshow";
          publisher = "ms-toolsai";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ms-vscode.anycode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.74";
          hash = "sha256-rTWAOvIsrl0DSqxoQy5eU6EREJovU1oRMC8/2Q6x4Hk=";
          name = "anycode";
          publisher = "ms-vscode";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ms-vscode.cmake-tools = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.23.52";
          hash = "sha256-LfYoKiiaETtlq4Jqe1bd5WaS5nBoci9K6BugZjgY2Ho=";
          name = "cmake-tools";
          publisher = "ms-vscode";
        };

        meta.license = lib.licenses.mit;
      };

      ms-vscode.cpptools = callPackage ./ms-vscode.cpptools { };

      ms-vscode.cpptools-extension-pack = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.5.1";
          hash = "sha256-5jmv/CnuAMwG8asvW2iW8j837ldnLZ3rJSQbNsNvN0M=";
          name = "cpptools-extension-pack";
          publisher = "ms-vscode";
        };

        meta = {
          description = "Popular extensions for C++ development in Visual Studio Code";
          homepage = "https://github.com/microsoft/vscode-cpptools";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.cpptools-extension-pack";
        };
      };

      ms-vscode.hexeditor = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.11.1";
          hash = "sha256-RB5YOp30tfMEzGyXpOwPIHzXqZlRGc+pXiJ3foego7Y=";
          name = "hexeditor";
          publisher = "ms-vscode";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ms-vscode.js-debug = callPackage ./ms-vscode.js-debug { };
      ms-vscode.js-debug-companion = callPackage ./ms-vscode.js-debug-companion { };

      ms-vscode.live-server = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.5.2024091601";
          hash = "sha256-cwntFW5McTAcFs0f+vTlLpZffz3ApYGxu0ctJ2X6EuY=";
          name = "live-server";
          publisher = "ms-vscode";
        };

        meta = {
          description = "Launch a development local Server with live reload feature for static & dynamic pages";
          homepage = "https://github.com/microsoft/vscode-livepreview";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.live-server";
        };
      };

      ms-vscode.makefile-tools = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.12.17";
          hash = "sha256-chHyYzKNEpyYMQX14pbQ/d9WKC+1QWtm8iKe6M8ZWWI=";
          name = "makefile-tools";
          publisher = "ms-vscode";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ms-vscode.powershell = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2025.4.0";
          hash = "sha256-RY7vRbYRDj2YZ9I5Q7hDykqdDZbRZy21rRVrwXj2soM=";
          name = "PowerShell";
          publisher = "ms-vscode";
        };

        meta = {
          description = "Visual Studio Code extension for PowerShell language support";
          homepage = "https://github.com/PowerShell/vscode-powershell";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.rhoriguchi ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.PowerShell";
        };
      };

      ms-vscode.remote-explorer = callPackage ./ms-vscode.remote-explorer { };

      ms-vscode.test-adapter-converter = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.1";
          hash = "sha256-gyyl379atZLgtabbeo26xspdPjLvNud3cZ6kEmAbAjU=";
          name = "test-adapter-converter";
          publisher = "ms-vscode";
        };

        meta = {
          description = "Visual Studio Code extension that converts from the Test Explorer UI API into native VS Code testing";
          homepage = "https://github.com/microsoft/vscode-test-adapter-converter";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode.test-adapter-converter";
        };
      };

      ms-vscode.vscode-js-profile-table = callPackage ./ms-vscode.vscode-js-profile-table { };
      ms-vscode.vscode-speech = callPackage ./ms-vscode.vscode-speech { };

      ms-vscode-remote.remote-containers = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.459.1";
          hash = "sha256-e5azL+9hluC/YyWb9uQxrr9p/9K2cYcUhalc9nZlOEg=";
          name = "remote-containers";
          publisher = "ms-vscode-remote";
        };

        meta = {
          description = "Open any folder or repository inside a Docker container";
          homepage = "https://code.visualstudio.com/docs/devcontainers/containers";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers.anthonyroussel ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers";
        };
      };

      ms-vscode-remote.remote-ssh = callPackage ./ms-vscode-remote.remote-ssh { };

      ms-vscode-remote.remote-ssh-edit = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.87.0";
          hash = "sha256-yeX6RAJl07d+SuYyGQFLZNcUzVKAsmPFyTKEn+y3GuM=";
          name = "remote-ssh-edit";
          publisher = "ms-vscode-remote";
        };

        meta = {
          description = "Visual Studio Code extension that complements the Remote SSH extension with syntax colorization, keyword intellisense, and simple snippets when editing SSH configuration files";
          homepage = "https://code.visualstudio.com/docs/remote/ssh";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers.pandapip1 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-ssh-edit";
        };
      };

      ms-vscode-remote.remote-wsl = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.104.3";
          hash = "sha256-IlNBcrgJ2qkbJtNOonZGkuJHYL8Ho7EVb2HlbMimxK8=";
          name = "remote-wsl";
          publisher = "ms-vscode-remote";
        };

        meta = {
          description = "Windows Subsystem for Linux support for Visual Studio Code";
          homepage = "https://code.visualstudio.com/docs/remote/wsl";
          changelog = "https://marketplace.visualstudio.com/items/ms-vscode-remote.remote-wsl/changelog";
          license = lib.licenses.unfree;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-wsl";
        };
      };

      ms-vscode-remote.vscode-remote-extensionpack =
        callPackage ./ms-vscode-remote.vscode-remote-extensionpack
          { };

      ms-vsliveshare.vsliveshare = callPackage ./ms-vsliveshare.vsliveshare { };
      ms-windows-ai-studio.windows-ai-studio = callPackage ./ms-windows-ai-studio.windows-ai-studio { };

      mshr-h.veriloghdl = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.28.1";
          hash = "sha256-+Pc9blI/n6JeokdUhWjLzicwBv90p4MjhK2rvpQ2xrA=";
          name = "veriloghdl";
          publisher = "mshr-h";
        };

        meta = {
          description = "Visual Studio Code extension for supporting Verilog-HDL, SystemVerilog, Bluespec and SystemVerilog";
          homepage = "https://github.com/mshr-h/vscode-verilog-hdl-support";
          changelog = "https://marketplace.visualstudio.com/items/mshr-h.VerilogHDL/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.newam ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=mshr-h.VerilogHDL";
        };
      };

      mskelton.npm-outdated = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.2.0";
          hash = "sha256-kHItIlTW+PIVXrLgzdGAoPeR6sWKuKl/QyJ5+TIv3/E=";
          name = "npm-outdated";
          publisher = "mskelton";
        };

        meta = {
          description = "Shows which packages are outdated in an npm project";
          homepage = "https://github.com/mskelton/vscode-npm-outdated";
          changelog = "https://marketplace.visualstudio.com/items/mskelton.npm-outdated/changelog";
          license = lib.licenses.isc;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=mskelton.npm-outdated";
        };
      };

      mskelton.one-dark-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.14.3";
          hash = "sha256-AYOX6I1R34HdNNdY9LpLkM/JHm/f1h+Q9HTtEnKMhdU=";
          name = "one-dark-theme";
          publisher = "mskelton";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      mvllow.rose-pine = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.15.2";
          hash = "sha256-5jXlCFk/86BL1yojTRuhRzS3XqcwcCpl/gmApcTdlBw=";
          name = "rose-pine";
          publisher = "mvllow";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      myriad-dreamin.tinymist = callPackage ./myriad-dreamin.tinymist { };
      natqe.reload = callPackage ./natqe.reload { };

      naumovs.color-highlight = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.8.0";
          hash = "sha256-mT2P1lEdW66YkDRN6fi0rmmvvyBfXiJjAUHns8a8ipE=";
          name = "color-highlight";
          publisher = "naumovs";
        };

        meta = {
          description = "Highlight web colors in your editor";
          homepage = "https://github.com/enyancc/vscode-ext-color-highlight";
          changelog = "https://marketplace.visualstudio.com/items/naumovs.color-highlight/changelog";
          license = lib.licenses.gpl3Only;
          maintainers = [ lib.maintainers.datafoo ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=naumovs.color-highlight";
        };
      };

      naumovs.theme-oceanicnext = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.4";
          hash = "sha256-romhWL3s0NVZ3kptSNT4/X9WkgakgNNfFElaBCo6jj4=";
          name = "theme-oceanicnext";
          publisher = "naumovs";
        };

        meta = {
          description = "Oceanic Next theme for VSCode + dimmed bg version for better looking UI";
          homepage = "https://github.com/voronianski/oceanic-next-color-scheme";
          license = lib.licenses.unlicense;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=naumovs.theme-oceanicnext";
        };
      };

      ndonfris.fish-lsp = callPackage ./ndonfris.fish-lsp { };

      nefrob.vscode-just-syntax = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.10.2";
          hash = "sha256-F7H9f24TjB3JtWLVICYwRTjxa+GTOpYN7IzSlU1audo=";
          name = "vscode-just-syntax";
          publisher = "nefrob";
        };

        meta = {
          description = "Justfile syntax support for Visual Studio Code";
          homepage = "https://github.com/nefrob/vscode-just";
          changelog = "https://marketplace.visualstudio.com/items/nefrob.vscode-just-syntax/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=nefrob.vscode-just-syntax";
        };
      };

      nhoizey.gremlins = callPackage ./nhoizey.gremlins { };
      nimlang.nimlang = callPackage ./nimlang.nimlang { };

      njpwerner.autodocstring = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.6.1";
          hash = "sha256-NI0cbjsZPW8n6qRTRKoqznSDhLZRUguP7Sa/d0feeoc=";
          name = "autodocstring";
          publisher = "njpwerner";
        };

        meta = {
          description = "Generates python docstrings automatically";
          homepage = "https://github.com/NilsJPWerner/autoDocstring";
          changelog = "https://marketplace.visualstudio.com/items/njpwerner.autodocstring/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.kamadorueda ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=njpwerner.autodocstring";
        };
      };

      nomicfoundation.hardhat-solidity = callPackage ./nomicfoundation.hardhat-solidity { };

      nonylene.dark-molokai-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.10";
          hash = "sha256-YBYlcf6TUPEQvmhL7mYfN59itKQvtWt9003/Bup15eg=";
          name = "dark-molokai-theme";
          publisher = "nonylene";
        };

        meta = {
          description = "Theme inspired by VSCode default dark theme, monokai theme and Vim Molokai theme";
          homepage = "https://github.com/nonylene/vscode-dark-molokai-theme";
          changelog = "https://marketplace.visualstudio.com/items/nonylene.dark-molokai-theme/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.amz-x ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=nonylene.dark-molokai-theme";
        };
      };

      nsd.vscode-epics = callPackage ./nsd.vscode-epics { };

      nur.just-black = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.1.1";
          hash = "sha256-fatJZquCDsLDFGVzBol2D6LIZUbZ6GzqcVEFAwLodW0=";
          name = "just-black";
          publisher = "nur";
        };

        meta = {
          description = "Dark theme designed specifically for syntax highlighting";
          homepage = "https://github.com/nurmohammed840/extension.vsix/tree/Just-Black";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=nur.just-black";
        };
      };

      ocamllabs.ocaml-platform = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.3.0";
          hash = "sha256-vb2tTtdHRmlF/TZRqUFjZNgE+5jizX/ky+NgzJYvXUg=";
          name = "ocaml-platform";
          publisher = "ocamllabs";
        };

        meta = {
          description = "Official OCaml Support from OCamlLabs";
          homepage = "https://github.com/ocamllabs/vscode-ocaml-platform";
          changelog = "https://marketplace.visualstudio.com/items/ocamllabs.ocaml-platform/changelog";
          license = lib.licenses.isc;
          maintainers = [ lib.maintainers.ratsclub ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ocamllabs.ocaml-platform";
        };
      };

      octref.vetur = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.37.3";
          hash = "sha256-3hi1LOZto5AYaomB9ihkAt4j/mhkCDJ8Jqa16piwHIQ=";
          name = "vetur";
          publisher = "octref";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      oderwat.indent-rainbow = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "8.3.1";
          hash = "sha256-dOicya0B2sriTcDSdCyhtp0Mcx5b6TUaFKVb0YU3jUc=";
          name = "indent-rainbow";
          publisher = "oderwat";
        };

        meta = {
          description = "Makes indentation easier to read";
          homepage = "https://github.com/oderwat/vscode-indent-rainbow";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.imgabe ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=oderwat.indent-rainbow";
        };
      };

      oliver-ni.scheme-fmt = callPackage ./oliver-ni.scheme-fmt { };
      oops418.nix-env-picker = callPackage ./oops418.nix-env-picker { };
      oracle.oracle-java = callPackage ./oracle.oracle-java { };
      oxc.oxc-vscode = callPackage ./oxc.oxc-vscode { };
      ph-hawkins.arc-plus = callPackage ./ph-hawkins.arc-plus { };

      phind.phind = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.25.4";
          hash = "sha256-qiUjDPJ35RZA4JYwFpQ//zwh9TKJ4RMtZmIzm3uThC0=";
          name = "phind";
          publisher = "phind";
        };

        meta = {
          description = "Using Phind AI service to provide answers based on the code context";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers.onny ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=phind.phind";
        };
      };

      phoenixframework.phoenix = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.3";
          hash = "sha256-UuGqYLz/4lc5WngrRLkAbEXnOW5pvTlDhHO0aB+LRgk=";
          name = "phoenix";
          publisher = "phoenixframework";
        };

        meta = {
          description = "Syntax highlighting support for HEEx / Phoenix templates";
          homepage = "https://github.com/phoenixframework/vscode-phoenix";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=phoenixframework.phoenix";
        };
      };

      piousdeer.adwaita-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.0";
          hash = "sha256-tKpKLUcc33YrgDS95PJu22ngxhwjqeVMC1Mhhy+IPGE=";
          name = "adwaita-theme";
          publisher = "piousdeer";
        };

        meta = {
          description = "Theme for the GNOME desktop";
          homepage = "https://github.com/piousdeer/vscode-adwaita";
          license = lib.licenses.gpl3;
          maintainers = [ lib.maintainers.wyndon ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=piousdeer.adwaita-theme";
        };
      };

      pkief.material-icon-theme = callPackage ./pkief.material-icon-theme { };

      pkief.material-product-icons = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.7.1";
          hash = "sha256-knYRG4j8cU6frLXSpwvaSyE+EWFd1ne/ctYa5kqp5bw=";
          name = "material-product-icons";
          publisher = "PKief";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      platformio.platformio-vscode-ide = callPackage ./platformio.platformio-vscode-ide { };

      pollywoggames.pico8-ls = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.6.1";
          hash = "sha256-TlULqIKb3R+bvjN3f4Bwha0bewqCHpPVFiePHNV2kmE=";
          name = "pico8-ls";
          publisher = "PollywogGames";
        };

        meta = {
          description = "VSCode extension for full language support for the PICO-8 dialect of Lua";
          homepage = "https://github.com/japhib/pico8-ls";
          changelog = "https://marketplace.visualstudio.com/items/PollywogGames.pico8-ls/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.dotmobo ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=PollywogGames.pico8-ls";
        };
      };

      pranaygp.vscode-css-peek = callPackage ./pranaygp.vscode-css-peek { };
      prettier.prettier-vscode = callPackage ./prettier.prettier-vscode { };
      prince781.vala = callPackage ./prince781.vala { };

      prisma.prisma = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "31.11.0";
          hash = "sha256-vvHr5jZ2lccO93O82OKnRF4wyVv3n/H3nKJIqZdIjlY=";
          name = "prisma";
          publisher = "Prisma";
        };

        meta = {
          description = "VSCode extension for syntax highlighting, formatting, auto-completion, jump-to-definition and linting for .prisma files";
          homepage = "https://github.com/prisma/language-tools";
          changelog = "https://marketplace.visualstudio.com/items/Prisma.prisma/changelog";
          license = lib.licenses.asl20;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Prisma.prisma";
        };
      };

      pylyzer.pylyzer = callPackage ./pylyzer.pylyzer { };

      pythagoratechnologies.gpt-pilot-vs-code = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.32";
          hash = "sha256-7wwvx1uvx2sJymCR/VYppyjDTmcF1eGJSvXTiND2fQs=";
          name = "gpt-pilot-vs-code";
          publisher = "PythagoraTechnologies";
        };

        meta = {
          description = "VSCode extension for assisting the developer to code, debug, build applications using LLMs/AI";
          homepage = "https://github.com/Pythagora-io/gpt-pilot/";
          changelog = "https://marketplace.visualstudio.com/items/PythagoraTechnologies.gpt-pilot-vs-code/changelog";
          license = lib.licenses.asl20;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=PythagoraTechnologies.gpt-pilot-vs-code";
        };
      };

      quicktype.quicktype = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "23.0.170";
          hash = "sha256-lK50+WXPXHgqryhlsMb+65yoebX0Rh3PNKmlUjfwlOc=";
          name = "quicktype";
          publisher = "quicktype";
        };

        meta = {
          description = "Infer types from sample JSON data";
          homepage = "https://github.com/glideapps/quicktype";
          license = lib.licenses.asl20;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=quicktype.quicktype";
        };
      };

      rebornix.ruby = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.28.1";
          hash = "sha256-HAUdv+2T+neJ5aCGiQ37pCO6x6r57HIUnLm4apg9L50=";
          name = "ruby";
          publisher = "rebornix";
        };

        meta.license = lib.licenses.mit;
      };

      redhat.ansible = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "26.6.0";
          hash = "sha256-pCq9niQQIBkiJL6q90W6ecSkGPHttiOAECAyrPgBeqg=";
          name = "ansible";
          publisher = "redhat";
        };

        meta = {
          description = "Ansible language support";
          homepage = "https://github.com/ansible/vscode-ansible";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=redhat.ansible";
        };
      };

      redhat.java = buildVscodeMarketplaceExtension {
        buildInputs = [ jdk ];

        mktplcRef = {
          version = "1.55.0";
          hash = "sha256-ARY5w+40e5WRiVv8d9jPKPg2wFPQpJrkqD7+ncRzpgM=";
          name = "java";
          publisher = "redhat";
        };

        meta = {
          description = "Java language support for VS Code via the Eclipse JDT Language Server";
          homepage = "https://github.com/redhat-developer/vscode-java";
          changelog = "https://marketplace.visualstudio.com/items/redhat.java/changelog";
          license = lib.licenses.epl20;
          maintainers = [ ];
          broken = lib.versionOlder jdk.version "17";
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=redhat.java";
        };
      };

      redhat.vscode-xml = callPackage ./redhat.vscode-xml { };

      redhat.vscode-yaml = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.24.0";
          hash = "sha256-Bmh1gxKn+mvtolnKWmhJ2QxdUZ32QV7b4kbBNeBtcWg=";
          name = "vscode-yaml";
          publisher = "redhat";
        };

        meta = {
          description = "YAML Language Support by Red Hat, with built-in Kubernetes syntax support";
          homepage = "https://github.com/redhat-developer/vscode-yaml";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml";
        };
      };

      reditorsupport.r = callPackage ./reditorsupport.r { };
      reditorsupport.r-syntax = callPackage ./reditorsupport.r-syntax { };
      release-candidate.vscode-scheme-repl = callPackage ./release-candidate.vscode-scheme-repl { };

      reloadedextensions.reloaded-cpp = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.9";
          hash = "sha256-KQiSD18W9NnsqhRt+XM3ko70u4zX4enn3OpMt0ebViU=";
          name = "reloaded-cpp";
          publisher = "reloadedextensions";
        };

        meta = {
          description = "C/C++ must-have highlighter that understands many coding styles and APIs. Use with 'Reloaded Themes' extension";
          homepage = "https://github.com/kobalicek/reloaded-cpp";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=reloadedextensions.reloaded-cpp";
        };
      };

      rioj7.commandonallfiles = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.5.1";
          hash = "sha256-sv42eRZV32KW51KVadzlrScHQ6snNkBDTzAJ8BDtAvU=";
          name = "commandOnAllFiles";
          publisher = "rioj7";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ritwickdey.liveserver = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "5.7.10";
          hash = "sha256-D474GdTCAH8b+zuO+1M+cnluKfBv7mAMdtH7F777W5U=";
          name = "liveserver";
          publisher = "ritwickdey";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      robocorp.robotframework-lsp = callPackage ./robocorp.robotframework-lsp { };

      rocq-prover.vsrocq = buildVscodeMarketplaceExtension {
        mktplcRef = {
          # When updating the version here, also update the language server vsrocq-language-server
          version = "2.4.3";
          hash = "sha256-o9rsSDCDYRWZQBMDA7DtWay50tBI76kw7H7CivrZpKo=";
          name = "vsrocq";
          publisher = "rocq-prover";
        };

        meta = {
          description = "VsRocq is an extension for Visual Studio Code with support for the Rocq Prover";
          homepage = "https://github.com/rocq-prover/vsrocq";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.Zimmi48 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=rocq-prover.vsrocq";
        };
      };

      roman.ayu-next = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.2.15";
          hash = "sha256-gGEjb9BrvFmKhAxRUmN3YWx7VZqlUp6w7m4r46DPn50=";
          name = "ayu-next";
          publisher = "roman";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      rooveterinaryinc.roo-cline = callPackage ./rooveterinaryinc.roo-cline { };

      rubbersheep.gi = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.11";
          name = "gi";
          publisher = "rubbersheep";
          sha256 = "0j9k6wm959sziky7fh55awspzidxrrxsdbpz1d79s5lr5r19rs6j";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      rubymaniac.vscode-paste-and-indent = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.8";
          name = "vscode-paste-and-indent";
          publisher = "Rubymaniac";
          sha256 = "0fqwcvwq37ndms6vky8jjv0zliy6fpfkh8d9raq8hkinfxq6klgl";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      rust-lang.rust-analyzer = callPackage ./rust-lang.rust-analyzer { };

      ryu1kn.partial-diff = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.4.6";
          name = "partial-diff";
          publisher = "ryu1kn";
          sha256 = "sha256-yp0w/atuZUSSVEaRLhpnX4NmrYCGwzFjEgzncRpEoNA=";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      sainnhe.gruvbox-material = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "6.5.2";
          hash = "sha256-D+SZEQQwjZeuyENOYBJGn8tqS3cJiWbEkmEqhNRY/i4=";
          name = "gruvbox-material";
          publisher = "sainnhe";
        };

        meta = {
          description = "Gruvbox Material theme VSCode extension with Material palette";
          homepage = "https://github.com/sainnhe/gruvbox-material-vscode";
          changelog = "https://marketplace.visualstudio.com/items/sainnhe.gruvbox-material/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ thtrf ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=sainnhe.gruvbox-material";
        };
      };

      samuelcolvin.jinjahtml = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.20.0";
          name = "jinjahtml";
          publisher = "samuelcolvin";
          sha256 = "c000cbdc090b7d3d8df62a3c87a5d881c78aca5b490b3e591d9841d788a9aa93";
        };

        meta = {
          description = "Syntax highlighting for jinja(2) including HTML, Markdown, YAML, Ruby and LaTeX templates";
          homepage = "https://github.com/samuelcolvin/jinjahtml-vscode";
          changelog = "https://marketplace.visualstudio.com/items/samuelcolvin.jinjahtml/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.DataHearth ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=samuelcolvin.jinjahtml";
        };
      };

      sanaajani.taskrunnercode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.3.0";
          name = "taskrunnercode";
          publisher = "sanaajani";
          sha256 = "NVGMM9ugmYZNCWhNmclcGuVJPhJ9h4q2G6nNzVUEpes=";
        };

        meta = {
          description = "Extension to view and run tasks from Explorer pane";

          longDescription = ''
            This extension adds an additional "Task Runner" view in your Explorer Pane
            to visualize and individually run the auto-detected or configured tasks
            in your project.
          '';

          homepage = "https://github.com/sana-ajani/taskrunner-code";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.pbsds ];
        };
      };

      saoudrizwan.claude-dev = callPackage ./saoudrizwan.claude-dev { };

      sas.sas-lsp = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.20.0";
          hash = "sha256-s2CAzAXMXdmCyOoMmyHjz5GRPHi5riDf/Og3SVrW7QI=";
          name = "sas-lsp";
          publisher = "SAS";
        };

        meta = {
          description = "Official SAS Language Extension";
          homepage = "https://github.com/sassoftware/vscode-sas-extension";
          changelog = "https://marketplace.visualstudio.com/items/SAS.sas-lsp/changelog";
          license = lib.licenses.asl20;
          maintainers = [ lib.maintainers.scraptux ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=SAS.sas-lsp";
        };
      };

      scala-lang.scala = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.5.10";
          hash = "sha256-hGJbu/tRt1Du/OYuui7z/CINlMug/SlUQjPNy8Rvkxg=";
          name = "scala";
          publisher = "scala-lang";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      scalameta.metals = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.67.0";
          hash = "sha256-THrd3Yix0gohTo/cshy9ZYZysA+xCGLx4KJHFk4zmCM=";
          name = "metals";
          publisher = "scalameta";
        };

        meta = {
          license = lib.licenses.asl20;
        };
      };

      sdras.night-owl = buildVscodeMarketplaceExtension rec {
        mktplcRef = {
          version = "2.1.1";
          hash = "sha256-mTvnUw/018p/1lJTje9rZ1JJXq4NiaI0d4UnRthnZtg=";
          name = "night-owl";
          publisher = "sdras";
        };

        meta = {
          description = "Visual Studio Code theme named Light Owl for daytime usage";

          longDescription = ''
            A VS Code theme for the night owls out there. Now introducing
            Light Owl theme for daytime usage. Decisions were based
            on meaningful contrast for reading comprehension and for
            optimal razzle dazzle.
          '';

          homepage = "https://github.com/sdras/night-owl-vscode-theme";

          changelog = "https://github.com/sdras/night-owl-vscode-theme/blob/main/CHANGELOG.md#${
            builtins.replaceStrings [ "." ] [ "" ] mktplcRef.version
          }";

          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.pladypus ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=sdras.night-owl";
        };
      };

      seatonjiang.gitmoji-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2026.3.6";
          hash = "sha256-9SeXoMbZFjRL4vXoior76WaLmgnxfrDa3X4zXu/RMaI=";
          name = "gitmoji-vscode";
          publisher = "seatonjiang";
        };

        meta = {
          description = "Gitmoji tool for git commit messages in VSCode";
          homepage = "https://github.com/seatonjiang/gitmoji-vscode/";
          changelog = "https://marketplace.visualstudio.com/items/seatonjiang.gitmoji-vscode/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=seatonjiang.gitmoji-vscode";
        };
      };

      serayuzgur.crates = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.6.7";
          hash = "sha256-FVZxMZ0QpCKLD0vX7LPvBywZgQ4kptjnCW9jCefwgJo=";
          name = "crates";
          publisher = "serayuzgur";
        };

        meta = {
          license = lib.licenses.mit;
          maintainers = [ ];
        };
      };

      shardulm94.trailing-spaces = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.4.4";
          hash = "sha256-L2WM021Jyyovy8KElkIspXc0MdHC9APsbPdX5hK4CIM=";
          name = "trailing-spaces";
          publisher = "shardulm94";
        };

        meta = {
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.kamadorueda ];
        };
      };

      shd101wyy.markdown-preview-enhanced = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.8.30";
          hash = "sha256-wtI+W+ZNxXv8WonGDmSt1NxeF8WN8fqPCuMougERxDE=";
          name = "markdown-preview-enhanced";
          publisher = "shd101wyy";
        };

        meta = {
          description = "Provides a live preview of markdown using either markdown-it or pandoc";

          longDescription = ''
            Markdown Preview Enhanced is an extension that provides you with
            many useful functionalities such as automatic scroll sync, math
            typesetting, mermaid, PlantUML, pandoc, PDF export, code chunk,
            presentation writer, etc. A lot of its ideas are inspired by
            Markdown Preview Plus and RStudio Markdown.
          '';

          homepage = "https://github.com/shd101wyy/vscode-markdown-preview-enhanced";
          license = lib.licenses.ncsa;
          maintainers = [ lib.maintainers.pbsds ];
        };
      };

      shopify.ruby-lsp = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.10.4";
          hash = "sha256-fonAbZ2nvC3Dz/9j4J23hiiJ/xgT8z/LI1HYYQh6u9w=";
          name = "ruby-lsp";
          publisher = "shopify";
        };

        meta = {
          description = "VS Code plugin for connecting with the Ruby LSP";
          license = lib.licenses.mit;
        };
      };

      shyykoserhiy.vscode-spotify = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.2.1";
          name = "vscode-spotify";
          publisher = "shyykoserhiy";
          sha256 = "14d68rcnjx4a20r0ps9g2aycv5myyhks5lpfz0syr2rxr4kd1vh6";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      signageos.signageos-vscode-sops = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.9.4";
          hash = "sha256-SH+hmxFQAXcL0MP9WToGmvdBjn/l2TWxF/YL30FwXes=";
          name = "signageos-vscode-sops";
          publisher = "signageos";
        };

        meta = {
          description = "Visual Studio Code extension for SOPS support";
          homepage = "https://github.com/signageos/vscode-sops";
          changelog = "https://marketplace.visualstudio.com/items/signageos.signageos-vscode-sops/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=signageos.signageos-vscode-sops";
        };
      };

      silofy.hackthebox = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.9";
          hash = "sha256-WSPuEh+osu0DpXgPAzMU5Fw0Sh8sZFst7kx26s2BsyQ=";
          name = "hackthebox";
          publisher = "silofy";
        };

        meta = {
          description = "Visual Studio Code theme built for hackers by hackers";
          homepage = "https://github.com/silofy/hackthebox";
          changelog = "https://marketplace.visualstudio.com/items/silofy.hackthebox/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=silofy.hackthebox";
        };
      };

      skellock.just = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.0.0";
          hash = "sha256-FOp/dcW0+07rADEpUMzx+SGYjhvE4IhcCOqUQ38yCN4=";
          name = "just";
          publisher = "skellock";
        };

        meta = {
          description = "Provides syntax and recipe launcher for Just scripts";
          homepage = "https://github.com/skellock/vscode-just";
          changelog = "https://github.com/skellock/vscode-just/blob/master/CHANGELOG.md";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.maximsmol ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=skellock.just";
        };
      };

      skyapps.fish-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.1";
          name = "fish-vscode";
          publisher = "skyapps";
          sha256 = "0y1ivymn81ranmir25zk83kdjpjwcqpnc9r3jwfykjd9x0jib2hl";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      slevesque.vscode-multiclip = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.5";
          name = "vscode-multiclip";
          publisher = "slevesque";
          sha256 = "1cg8dqj7f10fj9i0g6mi3jbyk61rs6rvg9aq28575rr52yfjc9f9";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      smcpeak.default-keys-windows = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.0";
          hash = "sha256-bS7HnO2avXkSwXmuZ0oe2Sj/q3YYLOV4ldaAak9w9RY=";
          name = "default-keys-windows";
          publisher = "smcpeak";
        };

        meta = {
          description = "VSCode extension that provides default Windows keybindings on any platform";
          homepage = "https://github.com/smcpeak/vscode-default-keys-windows";
          changelog = "https://github.com/smcpeak/vscode-default-keys-windows/blob/master/CHANGELOG.md";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.ttschnz ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=smcpeak.default-keys-windows";
        };
      };

      sonarsource.sonarlint-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "5.3.0";
          hash = "sha256-ic1/RhQdkY0WbHkLiw618Rg2jblkYKjprS8w98I7Pgc=";
          name = "sonarlint-vscode";
          publisher = "sonarsource";
        };

        meta.license = lib.licenses.lgpl3Only;
      };

      sourcegraph.amp = callPackage ./sourcegraph.amp { };
      sourcery.sourcery = callPackage ./sourcery.sourcery { };

      spywhere.guides = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.9.3";
          name = "guides";
          publisher = "spywhere";
          sha256 = "1kvsj085w1xax6fg0kvsj1cizqh86i0pkzpwi0sbfvmcq21i6ghn";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      sswg.swift-lang = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.12.0";
          hash = "sha256-Dzf8mJCDWT2pHPJcTywEqnki8aVsMO92+wLQ4fjHzb8=";
          name = "swift-lang";
          publisher = "sswg";
        };

        meta = {
          description = "Swift Language Support for Visual Studio Code";
          homepage = "https://github.com/swiftlang/vscode-swift";
          changelog = "https://marketplace.visualstudio.com/items/sswg.swift-lang/changelog";
          license = lib.licenses.asl20;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=sswg.swift-lang";
        };
      };

      stefanjarina.vscode-eex-snippets = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.8";
          name = "vscode-eex-snippets";
          publisher = "stefanjarina";
          sha256 = "0j8pmrs1lk138vhqx594pzxvrma4yl3jh7ihqm2kgh0cwnkbj36m";
        };

        meta = {
          description = "VSCode extension for Elixir EEx and HTML (EEx) code snippets";
          homepage = "https://github.com/stefanjarina/vscode-eex-snippets";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=stefanjarina.vscode-eex-snippets";
        };
      };

      stephlin.vscode-tmux-keybinding = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.0";
          hash = "sha256-ZV5iyZ8pkTG9RPGObFtGbU5Iq7w/cDlUMuOVskg/39g=";
          name = "vscode-tmux-keybinding";
          publisher = "stephlin";
        };

        meta = {
          description = "Simple extension for tmux behavior in vscode terminal";
          homepage = "https://github.com/StephLin/vscode-tmux-keybinding";
          changelog = "https://marketplace.visualstudio.com/items/stephlin.vscode-tmux-keybinding/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.dbirks ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=stephlin.vscode-tmux-keybinding";
        };
      };

      stkb.rewrap = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "17.8.0";
          hash = "sha256-9t1lpVbpcmhLamN/0ZWNEWD812S6tXG6aK3/ALJCJvg=";
          name = "rewrap";
          publisher = "stkb";
        };

        meta = {
          description = "Hard word wrapping for comments and other text at a given column";
          homepage = "https://github.com/stkb/Rewrap#readme";
          changelog = "https://github.com/stkb/Rewrap/blob/master/CHANGELOG.md";
          license = lib.licenses.asl20;
          maintainers = [ lib.maintainers.datafoo ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=stkb.rewrap";
        };
      };

      streetsidesoftware.code-spell-checker = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "4.5.6";
          hash = "sha256-AAakZeChN5HkhhqbGUWSMXm4Tbq7n+ydWutEDPUdRqQ=";
          name = "code-spell-checker";
          publisher = "streetsidesoftware";
        };

        meta = {
          description = "Spelling checker for source code";
          homepage = "https://streetsidesoftware.github.io/vscode-spell-checker";
          changelog = "https://marketplace.visualstudio.com/items/streetsidesoftware.code-spell-checker/changelog";
          license = lib.licenses.gpl3Only;
          maintainers = [ lib.maintainers.datafoo ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=streetsidesoftware.code-spell-checker";
        };
      };

      streetsidesoftware.code-spell-checker-french =
        callPackage ./streetsidesoftware.code-spell-checker-french
          { };

      streetsidesoftware.code-spell-checker-german =
        callPackage ./streetsidesoftware.code-spell-checker-german
          { };

      styled-components.vscode-styled-components = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.7.8";
          hash = "sha256-VoLAjBcAizTxd+BHwXoNSlSxqXno3PjVxaickLCtnsw=";
          name = "vscode-styled-components";
          publisher = "styled-components";
        };

        meta = {
          description = "Syntax highlighting and IntelliSense for styled-components";
          homepage = "https://github.com/styled-components/vscode-styled-components";
          changelog = "https://marketplace.visualstudio.com/items/styled-components.vscode-styled-components/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=styled-components.vscode-styled-components";
        };
      };

      stylelint.vscode-stylelint = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.2.1";
          hash = "sha256-VnJ2OZe2KPo/QfZquxDZ3SMQncRWnAHBTTtfdJVBlpo=";
          name = "vscode-stylelint";
          publisher = "stylelint";
        };

        meta = {
          description = "Official Stylelint extension for Visual Studio Code";
          homepage = "https://github.com/stylelint/vscode-stylelint";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=stylelint.vscode-stylelint";
        };
      };

      sumneko.lua = callPackage ./sumneko.lua { };

      supermaven.supermaven = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.12";
          hash = "sha256-/fZungx+wdtKo80KCGZa4WfHMTT6Imb5MBgQ8gAGhfQ=";
          name = "supermaven";
          publisher = "supermaven";
        };

        meta = {
          description = "Visual Studio Code extension for code completion suggestions";

          longDescription = ''
            Supermaven uses a 300,000 token context window to provide you the best code completion suggestions and the lowest latency.
            With our extension you will get the fastest and best completions of any tool on the market.
          '';

          homepage = "https://supermaven.com/";
          changelog = "https://marketplace.visualstudio.com/items/supermaven.supermaven/changelog";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers.msanft ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=supermaven.supermaven";
        };
      };

      svelte.svelte-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "110.2.1";
          hash = "sha256-NcidslqM4AVrobOaxW1EBpMoBCTn2Bej86phIVU2psc=";
          name = "svelte-vscode";
          publisher = "svelte";
        };

        meta = {
          description = "Svelte language support for VS Code";
          homepage = "https://github.com/sveltejs/language-tools#readme";
          changelog = "https://github.com/sveltejs/language-tools/releases";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.fabianhauser ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=svelte.svelte-vscode";
        };
      };

      svsool.markdown-memo = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.3.19";
          hash = "sha256-JRM9Tm7yql7dKXOdpTwBVR/gx/nwvM7qqrCNlV2i1uI=";
          name = "markdown-memo";
          publisher = "svsool";
        };

        meta = {
          description = "Markdown knowledge base with bidirectional [[link]]s built on top of VSCode";
          homepage = "https://github.com/svsool/vscode-memo";
          changelog = "https://marketplace.visualstudio.com/items/svsool.markdown-memo/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.ratsclub ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=svsool.markdown-memo";
        };
      };

      sysdig.sysdig-vscode-ext = callPackage ./sysdig.sysdig-vscode-ext { };

      tabnine.tabnine-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.335.0";
          hash = "sha256-+OPNX/mo29ZGOBnfi9sPSxKEiDHBZ8UFlbhjtC6E1VM=";
          name = "tabnine-vscode";
          publisher = "tabnine";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      tailscale.vscode-tailscale = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.0";
          name = "vscode-tailscale";
          publisher = "tailscale";
          sha256 = "sha256-kDvA4Yw+iFoBwHKrmQCwrPZRRSDvDyxTFc1Z1vAJwc0=";
        };

        meta = {
          description = "VSCode extension to share a port over the internet with Tailscale Funnel";
          homepage = "https://github.com/tailscale-dev/vscode-tailscale";
          changelog = "https://marketplace.visualstudio.com/items/tailscale.vscode-tailscale/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Tailscale.vscode-tailscale";
        };
      };

      takayama.vscode-qq = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.4.2";
          hash = "sha256-koeiFXUFI/i8EGCRDTym62m7JER18J9MKZpbAozr0Ng=";
          name = "vscode-qq";
          publisher = "takayama";
        };

        meta = {
          license = lib.licenses.mpl20;
        };
      };

      tal7aouy.icons = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.8.0";
          hash = "sha256-PdhNFyVUWcOfli/ZlT+6TmtWrV31fBP1E1Vd4QWOY+A=";
          name = "icons";
          publisher = "tal7aouy";
        };

        meta = {
          description = "Icons for Visual Studio Code";
          homepage = "https://github.com/tal7aouy/vscode-icons";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=tal7aouy.icons";
        };
      };

      tamasfe.even-better-toml = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.21.2";
          hash = "sha256-IbjWavQoXu4x4hpEkvkhqzbf/NhZpn8RFdKTAnRlCAg=";
          name = "even-better-toml";
          publisher = "tamasfe";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      tauri-apps.tauri-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.9";
          hash = "sha256-ySfsmKAReKTLl6lHax2fnPu9paQ2pBSEMUoeGtGJelA=";
          name = "tauri-vscode";
          publisher = "tauri-apps";
        };

        meta = {
          description = "Enhances the experience of Tauri apps development";
          homepage = "https://github.com/tauri-apps/tauri-vscode";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=tauri-apps.tauri-vscode";
        };
      };

      tboby.cwtools-vscode = callPackage ./tboby.cwtools-vscode { };

      teabyii.ayu = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.1.12";
          name = "ayu";
          publisher = "teabyii";
          sha256 = "sha256-pwLvik3GRMLyr6GeTmZh1MrkgH1MgbyoembNmQxg4I0=";
        };

        meta = {
          description = "Simple theme with bright colors and comes in three versions — dark, light and mirage for all day long comfortable work";
          homepage = "https://github.com/ayu-theme/vscode-ayu";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=teabyii.ayu";
        };
      };

      teamtype.teamtype = callPackage ./teamtype.teamtype { };

      techtheawesome.rust-yew = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.3";
          hash = "sha256-JEFNYSyGCsmsiJ89R4fWy/cUU6pDW1HA2P1Sr90QJHU=";
          name = "rust-yew";
          publisher = "techtheawesome";
        };

        meta = {
          description = "VSCode extension that provides some language features for Yew's html macro syntax";
          homepage = "https://github.com/TechTheAwesome/code-yew-server";
          license = lib.licenses.gpl3Only;
          maintainers = [ lib.maintainers.CardboardTurkey ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=TechTheAwesome.rust-yew";
        };
      };

      tecosaur.latex-utilities = callPackage ./tecosaur.latex-utilities { };
      tekumara.typos-vscode = callPackage ./tekumara.typos-vscode { };
      teros-technology.teroshdl = callPackage ./teros-technology-teroshdl { };

      theangryepicbanana.language-pascal = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.6";
          name = "language-pascal";
          publisher = "theangryepicbanana";
          sha256 = "096wwmwpas21f03pbbz40rvc792xzpl5qqddzbry41glxpzywy6b";
        };

        meta = {
          description = "VSCode extension for high-quality Pascal highlighting";
          homepage = "https://github.com/ALANVF/vscode-pascal-magic";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=theangryepicbanana.language-pascal";
        };
      };

      thenuprojectcontributors.vscode-nushell-lang = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.0.5";
          hash = "sha256-358QR9JcLWbqEb0xPv1P42a+emibOEEFRtelkBPPJgc=";
          name = "vscode-nushell-lang";
          publisher = "thenuprojectcontributors";
        };

        meta.license = lib.licenses.mit;
      };

      thorerik.hacker-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.0.1";
          hash = "sha256-Ugk9kTJxW1kbD+X6PF96WBc1k7x4KaGu5WbCYPGQ3qE=";
          name = "hacker-theme";
          publisher = "thorerik";
        };

        meta = {
          description = "Perfect theme for writing IP tracers in Visual Basic and reverse-proxying a UNIX-system firewall";
          homepage = "https://github.com/thorerik/vscode-hacker-theme";
          changelog = "https://marketplace.visualstudio.com/items/thorerik.hacker-theme/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=thorerik.hacker-theme";
        };
      };

      tiehuis.zig = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.6";
          hash = "sha256-s0UMY0DzEufEF+pizYeH4MKYOiiJ6z05gYHvfpaS4zA=";
          name = "zig";
          publisher = "tiehuis";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      tim-koehler.helm-intellisense = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.15.0";
          hash = "sha256-Tl0X2jtgTsjf2tvyAJLGxEGrmLXACYWWErcDJuQYg+o=";
          name = "helm-intellisense";
          publisher = "Tim-Koehler";
        };

        meta = {
          description = "Extension to help writing Helm-Templates by providing intellisense";
          homepage = "https://github.com/tim-koehler/Helm-Intellisense";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Tim-Koehler.helm-intellisense";
        };
      };

      timonwong.shellcheck = callPackage ./timonwong.shellcheck { };

      tobiasalthoff.atom-material-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.10.9";
          hash = "sha256-EdU0FMkaQpwhOpPRC+HGIxcrt7kSN+l4+mSgIwogB/I=";
          name = "atom-material-theme";
          publisher = "tobiasalthoff";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      tombi-toml.tombi = callPackage ./tombi-toml.tombi { };

      tomblind.local-lua-debugger-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.3.3";
          hash = "sha256-7uZHbhOa/GT9F7+xikaxuQXIGzre1q1uWTWaTJhi2UA=";
          name = "local-lua-debugger-vscode";
          publisher = "tomblind";
        };

        meta = {
          description = "Simple Lua debugger for Visual Studio Code which requires no additional dependencies";
          homepage = "https://github.com/tomblind/local-lua-debugger-vscode";
          changelog = "https://github.com/tomblind/local-lua-debugger-vscode/blob/master/CHANGELOG.md";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode";
        };
      };

      tomoki1207.pdf = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.2.2";
          hash = "sha256-i3Rlizbw4RtPkiEsodRJEB3AUzoqI95ohyqZ0ksROps=";
          name = "pdf";
          publisher = "tomoki1207";
        };

        meta = {
          description = "Show PDF preview in VSCode";
          homepage = "https://github.com/tomoki1207/vscode-pdfviewer";
          license = lib.licenses.mit;
        };
      };

      tsandall.opa = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.23.0";
          hash = "sha256-xya4Kxjc/uR4LFTZ5fAVOa0/cyHy8XHZkkapmODyMK4=";
          name = "opa";
          publisher = "tsandall";
        };

        meta = {
          description = "Extension for VS Code which provides support for OPA";
          homepage = "https://github.com/open-policy-agent/vscode-opa";
          changelog = "https://github.com/open-policy-agent/vscode-opa/blob/master/CHANGELOG.md";
          license = lib.licenses.asl20;
          maintainers = [ lib.maintainers.msanft ];
        };
      };

      tsyesika.guile-scheme-enhanced = callPackage ./tsyesika.guile-scheme-enhanced { };

      tuttieee.emacs-mcx = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.110.11";
          hash = "sha256-LiiZI0Ze5F5w7OtiqY7wMpzdtyof/ynUH57wRfQnxFs=";
          name = "emacs-mcx";
          publisher = "tuttieee";
        };

        meta = {
          description = "Awesome Emacs Keymap - VSCode emacs keybinding with multi cursor support";
          homepage = "https://github.com/whitphx/vscode-emacs-mcx";
          changelog = "https://github.com/whitphx/vscode-emacs-mcx/blob/main/CHANGELOG.md";
          license = lib.licenses.mit;
        };
      };

      twpayne.vscode-testscript = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.7";
          hash = "sha256-M7uowipFpEVqY6foLbOLMB0AI+DrXj/h25+EceiwlMw=";
          name = "vscode-testscript";
          publisher = "twpayne";
        };

        meta = {
          description = "Syntax highlighting support for testscript";
          homepage = "https://github.com/twpayne/vscode-testscript";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=twpayne.vscode-testscript";
        };
      };

      twxs.cmake = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.17";
          hash = "sha256-CFiva1AO/oHpszbpd7lLtDzbv1Yi55yQOQPP/kCTH4Y=";
          name = "cmake";
          publisher = "twxs";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      tyriar.sort-lines = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.12.0";
          hash = "sha256-/uzwBLQMmp5zuoE0fWG2m7Ix8k33LQG2uaF0NVQt7sk=";
          name = "sort-lines";
          publisher = "Tyriar";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      ufo5260987423.magic-scheme = callPackage ./ufo5260987423.magic-scheme { };

      uiua-lang.uiua-vscode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.70";
          hash = "sha256-chp6chYUg3HzWm68NfSs3B8obSJxPSCjFHMwBK31ps4=";
          name = "uiua-vscode";
          publisher = "uiua-lang";
        };

        meta = {
          description = "VSCode language extension for Uiua";
          homepage = "https://github.com/uiua-lang/uiua-vscode";
          license = lib.licenses.mit;

          maintainers = with lib.maintainers; [
            tomasajt
            defelo
          ];

          downloadPage = "https://marketplace.visualstudio.com/items?itemName=uiua-lang.uiua-vscode";
        };
      };

      uloco.theme-bluloco-light = buildVscodeMarketplaceExtension {
        postInstall = ''
          rm -r $out/share/vscode/extensions/uloco.theme-bluloco-light/screenshots
        '';

        mktplcRef = {
          version = "3.7.5";
          name = "theme-bluloco-light";
          publisher = "uloco";
          sha256 = "sha256-MDrw0JWioLyg+H0XOCpULsmtM/y7RfV9ruDtskRiT3A=";
        };

        meta = {
          description = "Fancy but yet sophisticated light designer color scheme / theme for Visual Studio Code";
          homepage = "https://github.com/uloco/theme-bluloco-light";
          license = lib.licenses.lgpl3;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=uloco.theme-bluloco-light";
        };
      };

      unifiedjs.vscode-mdx = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.8.17";
          hash = "sha256-DTbgGVBnT6t++AFq08QmWNCKbbjvNPXMKoHgSL+UzyE=";
          name = "vscode-mdx";
          publisher = "unifiedjs";
        };

        meta = {
          description = "VSCode language support for MDX";
          homepage = "https://github.com/mdx-js/mdx-analyzer#readme";
          changelog = "https://marketplace.visualstudio.com/items/unifiedjs.vscode-mdx/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://github.com/mdx-js/mdx-analyzer";
        };
      };

      usernamehw.errorlens = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.28.0";
          hash = "sha256-7eu7y9IR1uxSFZ0IplDieFt3iWbcmdwf1lAcXq+S4C8=";
          name = "errorlens";
          publisher = "usernamehw";
        };

        meta = {
          description = "Visual Studio Code extension that improves highlighting of errors, warnings and other language diagnostics";
          homepage = "https://github.com/usernamehw/vscode-error-lens";
          changelog = "https://marketplace.visualstudio.com/items/usernamehw.errorlens/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.imgabe ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=usernamehw.errorlens";
        };
      };

      vadimcn.vscode-lldb = callPackage ./vadimcn.vscode-lldb { };

      valentjn.vscode-ltex = vscode-utils.buildVscodeMarketplaceExtension rec {
        nativeBuildInputs = [
          jq
          moreutils
        ];

        buildInputs = [ jdk ];

        postInstall = ''
          cd "$out/$installPrefix"
          jq '.contributes.configuration.properties."ltex.java.path".default = "${jdk}"' package.json | sponge package.json
        '';

        mktplcRef = {
          version = "13.1.0";
          name = "vscode-ltex";
          publisher = "valentjn";
        };

        vsix = fetchurl {
          name = "${mktplcRef.publisher}-${mktplcRef.name}.vsix";
          sha256 = "1nlrijjwc35n1xgb5lgnr4yvlgfcxd0vdj93ip8lv2xi8x1ni5f6";
          url = "https://github.com/valentjn/vscode-ltex/releases/download/${mktplcRef.version}/vscode-ltex-${mktplcRef.version}-offline-linux-x64.vsix";
        };

        meta = {
          license = lib.licenses.mpl20;
          maintainers = [ ];
        };
      };

      viktorqvarfordt.vscode-pitch-black-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.3.0";
          hash = "sha256-1JDm/cWNWwxa1gNsHIM/DIvqjXsO++hAf0mkjvKyi4g=";
          name = "vscode-pitch-black-theme";
          publisher = "ViktorQvarfordt";
        };

        meta = {
          license = lib.licenses.mit;
          maintainers = [ ];
        };
      };

      vincaslt.highlight-matching-tag = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.11.0";
          hash = "sha256-PxngjprSpWtD2ZDZfh+gOnZ+fVk5rvgGdZFxqbE21CY=";
          name = "highlight-matching-tag";
          publisher = "vincaslt";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      visualjj.visualjj = callPackage ./visualjj.visualjj { };

      visualstudioexptteam.intellicode-api-usage-examples = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.2.9";
          hash = "sha256-8xBD+WLBaxYt8v3+8lvV2SiqV89iE4jeQod2kH7LNHU=";
          name = "intellicode-api-usage-examples";
          publisher = "VisualStudioExptTeam";
        };

        meta = {
          description = "See relevant code examples from GitHub for over 100K different APIs right in your editor";
          homepage = "https://github.com/MicrosoftDocs/intellicode";
          license = lib.licenses.cc-by-40;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.intellicode-api-usage-examples";
        };
      };

      visualstudioexptteam.vscodeintellicode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.3.2";
          hash = "sha256-2zexyX1YKD5jgtsvDx7/z3luh5We71ys+XRlVcNywfs=";
          name = "vscodeintellicode";
          publisher = "VisualStudioExptTeam";
        };

        meta = {
          description = "AI-assisted development";
          homepage = "https://github.com/MicrosoftDocs/intellicode";
          license = lib.licenses.cc-by-40;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=VisualStudioExptTeam.vscodeintellicode";
        };
      };

      visualstudiotoolsforunity.vstuc = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.2.2";
          hash = "sha256-Yh4nhRTOmQiL34wYnd7Y2OMdl837fexRm5r2hHfhjIg=";
          name = "vstuc";
          publisher = "VisualStudioToolsForUnity";
        };

        meta = {
          description = "Integrates Visual Studio Code for Unity";
          homepage = "https://github.com/MicrosoftDocs/vscode-dotnettools";
          license = lib.licenses.unfree;
          maintainers = [ lib.maintainers.mib ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=visualstudiotoolsforunity.vstuc";
        };
      };

      vitaliymaz.vscode-svg-previewer = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.7.0";
          hash = "sha256-iX+Js2Pqz1gLDwrihuYtDwQG4ek7GiOhL3M0j3jHF/Y=";
          name = "vscode-svg-previewer";
          publisher = "vitaliymaz";
        };

        meta = {
          description = "Preview SVGs in VS Code";
          homepage = "https://github.com/vitaliymaz/vscode-svg-previewer";
          changelog = "https://marketplace.visualstudio.com/items/vitaliymaz.vscode-svg-previewer/changelog";
          license = lib.licenses.unfree;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=vitaliymaz.vscode-svg-previewer";
        };
      };

      vitest.explorer = callPackage ./vitest.explorer { };

      vlanguage.vscode-vlang = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.14";
          hash = "sha256-hlBALxBs5wZZFk4lgAkdkGs731Xuc2p0qxffOW6mMWQ=";
          name = "vscode-vlang";
          publisher = "vlanguage";
        };

        meta = {
          description = "V language support (syntax highlighting, formatter, snippets) for Visual Studio Code";
          homepage = "https://github.com/vlang/vscode-vlang";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=vlanguage.vscode-vlang";
        };
      };

      vscjava.vscode-gradle = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.17.3";
          hash = "sha256-heFcGOe10r7y23xyFc/nFKk/nsrX4wc5fT9e4GKGhW0=";
          name = "vscode-gradle";
          publisher = "vscjava";
        };

        meta = {
          description = "Visual Studio Code extension for Gradle build tool";
          homepage = "https://github.com/microsoft/vscode-gradle";
          changelog = "https://marketplace.visualstudio.com/items/vscjava.vscode-gradle/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ rhoriguchi ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-gradle";
        };
      };

      vscjava.vscode-java-debug = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.59.0";
          hash = "sha256-5Zc/zXY6mE6k1uV2RMz49f5sqoDA5YnylAPwDJrOOSA=";
          name = "vscode-java-debug";
          publisher = "vscjava";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      vscjava.vscode-java-dependency = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.27.5";
          hash = "sha256-epLCQeNIZkwM8U/dKQ1dIAlWVKts2AlJivhSuJHXy2o=";
          name = "vscode-java-dependency";
          publisher = "vscjava";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      vscjava.vscode-java-pack = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.31.1";
          hash = "sha256-SfrsL27uQyrtsNyqZe0q5Fv5sHMwRvBZ+iS6/JIpFVo=";
          name = "vscode-java-pack";
          publisher = "vscjava";
        };

        meta = {
          description = "Popular extensions for Java development that provides Java IntelliSense, debugging, testing, Maven/Gradle support, project management and more";
          homepage = "https://github.com/Microsoft/vscode-java-pack";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.themaxmur ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=vscjava.vscode-java-pack";
        };
      };

      vscjava.vscode-java-test = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.45.0";
          hash = "sha256-6GEuijuVilhJ73isdrZPzD+xhZjRDXYQNCgcSBoyIdo=";
          name = "vscode-java-test";
          publisher = "vscjava";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      vscjava.vscode-maven = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.45.3";
          hash = "sha256-LR0vfQ5P81uIJPoY0CuieyjjePMwJo75TDMCpZwi80g=";
          name = "vscode-maven";
          publisher = "vscjava";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      vscjava.vscode-spring-initializr = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.12.0";
          hash = "sha256-q2++9C01okq5pFdmKKc3ZSr0G4XTAchpEmBMqZm3q7Y=";
          name = "vscode-spring-initializr";
          publisher = "vscjava";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      vscode-icons-team.vscode-icons = callPackage ./vscode-icons-team.vscode-icons { };

      vscodevim.vim = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.32.4";
          hash = "sha256-+hyJZinWsa6U+s0fdrx2wUi6tOV3FNKf8O1qMMZEdkQ=";
          name = "vim";
          publisher = "vscodevim";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      vspacecode.vspacecode = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.10.20";
          hash = "sha256-UlEuCvsGgtKl1IaRuMn5ODm4NDe8NTbaMN8c476Z0g0=";
          name = "vspacecode";
          publisher = "VSpaceCode";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      vspacecode.whichkey = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.11.4";
          hash = "sha256-mgvI/8Y3naw3Zmud73UYcAEKz6B0Q4tf+0uL3UWcAD0=";
          name = "whichkey";
          publisher = "VSpaceCode";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      vue.volar = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.3.7";
          hash = "sha256-qXbJCRzHc7QS4QLCGso5orfSiRYp6V2wz/4tvyU3rfg=";
          name = "volar";
          publisher = "Vue";
        };

        meta = {
          description = "Official Vue VSCode extension";
          homepage = "https://github.com/vuejs/language-tools";
          changelog = "https://github.com/vuejs/language-tools/blob/master/CHANGELOG.md";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Vue.volar";
        };
      };

      vue.vscode-typescript-vue-plugin = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.8.27";
          hash = "sha256-ym1+WPKBcn4h9lqSFVehfiDoGUEviOSEVXVLhHcYvfc=";
          name = "vscode-typescript-vue-plugin";
          publisher = "Vue";
        };

        meta = {
          description = "Vue VSCode extension for TypeScript";
          homepage = "https://github.com/vuejs/language-tools";
          changelog = "https://marketplace.visualstudio.com/items/Vue.vscode-typescript-vue-plugin/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=Vue.vscode-typescript-vue-plugin";
        };
      };

      vytautassurvila.csharp-ls = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.33";
          hash = "sha256-VsNjdPmnstXgmgxzbC7+IGFggfLtYlQFsH3tGWjdUhM=";
          name = "csharp-ls";
          publisher = "vytautassurvila";
        };

        meta = {
          description = "Visual Studio Code Extension - C# LSP client for csharp-language-server";
          homepage = "https://github.com/vytautassurvila/vscode-csharp-ls";
          changelog = "https://github.com/vytautassurvila/vscode-csharp-ls/blob/master/CHANGELOG.md";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=vytautassurvila.csharp-ls";
        };
      };

      w88975.code-translate = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.20";
          hash = "sha256-blqLK7S+RmEoyr9zktS5/SNC0GeSXnNpbhltyajoAfw=";
          name = "code-translate";
          publisher = "w88975";
        };

        meta = {
          description = "Visual Studio Code extension to provide purely hover translation";

          longDescription = ''
            Code Translate is a purely hover translation extension
            - Non-intrusive display of translation results: perfectly integrated with VS Code code analysis.
            - Powerful word splitting capabilities: supports various forms of word splitting such as camel case and underscore.
            - Rich local vocabulary: includes 3.4+ million offline words, supporting various rare words.
            - Based on a rich local vocabulary: Code Translate has super-fast query speed, with each word typically queried in less than 10ms.
            - Multi-platform support: supports both the desktop version and online version of VS Code, and the plugin can be used on both versions.
          '';

          homepage = "https://github.com/w88975/code-translate-vscode";
          changelog = "https://marketplace.visualstudio.com/items/w88975.code-translate/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ onedragon ];
        };
      };

      waderyan.gitblame = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "13.1.0";
          name = "gitblame";
          publisher = "waderyan";
          sha256 = "sha256-32ohvlIV7ogX+hGgcrCyHrv2hKWSpi+YuRMv0SGDYYA=";
        };

        meta = {
          description = "Visual Studio Code Extension - See Git Blame info in status bar";
          homepage = "https://github.com/Sertion/vscode-gitblame";
          changelog = "https://marketplace.visualstudio.com/items/waderyan.gitblame/changelog";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=waderyan.gitblame";
        };
      };

      wakatime.vscode-wakatime = callPackage ./WakaTime.vscode-wakatime { };
      wgsl-analyzer.wgsl-analyzer = callPackage ./wgsl-analyzer.wgsl-analyzer { };

      wholroyd.jinja = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.8";
          name = "jinja";
          publisher = "wholroyd";
          sha256 = "1ln9gly5bb7nvbziilnay4q448h9npdh7sd9xy277122h0qawkci";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      wingrunr21.vscode-ruby = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.28.0";
          hash = "sha256-H3f1+c31x+lgCzhgTb0uLg9Bdn3pZyJGPPwfpCYrS70=";
          name = "vscode-ruby";
          publisher = "wingrunr21";
        };

        meta.license = lib.licenses.mit;
      };

      wix.vscode-import-cost = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.3.0";
          name = "vscode-import-cost";
          publisher = "wix";
          sha256 = "0wl8vl8n0avd6nbfmis0lnlqlyh4yp3cca6kvjzgw5xxdc5bl38r";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      wmaurer.change-case = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.0.0";
          hash = "sha256-tN/jlG2PzuiCeERpgQvdqDoa3UgrUaM7fKHv6KFqujc=";
          name = "change-case";
          publisher = "wmaurer";
        };

        meta = {
          description = "VSCode extension for quickly changing the case (camelCase, CONSTANT_CASE, snake_case, etc) of the current selection or current word";
          homepage = "https://github.com/wmaurer/vscode-change-case";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=wmaurer.change-case";
        };
      };

      woberg.godot-dotnet-tools = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.5.1";
          hash = "sha256-qZdQiW1RvzUR5+5QlVdMPBY82IOPUPs3GNOl6bOhnWM=";
          name = "godot-dotnet-tools";
          publisher = "woberg";
        };

        meta = {
          description = "VSCode extension for Godot 4 Mono supporting C# language";
          homepage = "https://github.com/williamoberg/godot-dotnet-tools";
          license = lib.licenses.mit;
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=woberg.godot-dotnet-tools";
          # For instructions on configuring this extension see:
          # https://wiki.nixos.org/wiki/Godot-Mono
        };
      };

      xadillax.viml = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.2.0";
          hash = "sha256-WNwTWJ3fDdIc9gsfOdtAd6Rg3xH0sbs6ONo7fKjtJuI=";
          name = "viml";
          publisher = "xadillax";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      xaver.clang-format = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.9.0";
          name = "clang-format";
          publisher = "xaver";
          sha256 = "abd0ef9176eff864f278c548c944032b8f4d8ec97d9ac6e7383d60c92e258c2f";
        };

        meta = {
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.zeratax ];
        };
      };

      xdebug.php-debug = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.40.1";
          hash = "sha256-WI4d6Kk+lEmFTYYfwSH7q32YaOeokdEquFtZQJcyyDA=";
          name = "php-debug";
          publisher = "xdebug";
        };

        meta = {
          description = "PHP Debug Adapter";
          homepage = "https://github.com/xdebug/vscode-php-debug";
          changelog = "https://github.com/xdebug/vscode-php-debug/blob/main/CHANGELOG.md";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.onny ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=xdebug.php-debug";
        };
      };

      xyz.local-history = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.8.1";
          name = "local-history";
          publisher = "xyz";
          sha256 = "1mfmnbdv76nvwg4xs3rgsqbxk8hw9zr1b61har9c3pbk9r4cay7v";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      yoavbls.pretty-ts-errors = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.8.7";
          hash = "sha256-ofh19dkK+b1+eqr5g4opoLg3a06C/qqC0HVws28jI/A=";
          name = "pretty-ts-errors";
          publisher = "yoavbls";
        };

        meta = {
          description = "Make TypeScript errors prettier and human-readable in VSCode";
          homepage = "https://github.com/yoavbls/pretty-ts-errors";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=yoavbls.pretty-ts-errors";
        };
      };

      yoshi47.selection-path-copier = callPackage ./yoshi47.selection-path-copier { };
      yy0931.vscode-sqlite3-editor = callPackage ./yy0931.vscode-sqlite3-editor { };
      yzane.markdown-pdf = callPackage ./yzane.markdown-pdf { };

      yzhang.dictionary-completion = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "1.3.1";
          hash = "sha256-sin2kTx7aXFPhtraKUjsowuV8Z2z237RIePL4F/JiPM=";
          name = "dictionary-completion";
          publisher = "yzhang";
        };

        meta = {
          description = "Visual Studio Code extension to help user easyly finish long words ";

          longDescription = ''
            Dictionary completion allows user to get a list of keywords, based off of the current word at the cursor.
            This is useful if you are typing a long word (e.g. acknowledgeable) and don't want to finish typing or don't remember the Spelling
          '';

          homepage = "https://github.com/yzhang-gh/vscode-dic-completion#readme";
          changelog = "https://marketplace.visualstudio.com/items/yzhang.dictionary-completion/changelog";
          license = lib.licenses.mit;
          maintainers = with lib.maintainers; [ onedragon ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=yzhang.dictionary-completion";
        };
      };

      yzhang.markdown-all-in-one = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.6.3";
          name = "markdown-all-in-one";
          publisher = "yzhang";
          sha256 = "sha256-xJhbFQSX1DDDp8iE/R8ep+1t5IRusBkvjHcNmvjrboM=";
        };

        meta = {
          description = "All you need to write Markdown (keyboard shortcuts, table of contents, auto preview and more)";
          homepage = "https://github.com/yzhang-gh/vscode-markdown";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one";
        };
      };

      zaaack.markdown-editor = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.1.17";
          hash = "sha256-j7K1MS9XBLwCjER41NsSt22LUh0Zmm2sUK9JqZLiSfk=";
          name = "markdown-editor";
          publisher = "zaaack";
        };

        meta = {
          description = "Visual Studio Code extension for WYSIWYG markdown editing";
          homepage = "https://github.com/zaaack/vscode-markdown-editor";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.pandapip1 ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=zaaack.markdown-editor";
        };
      };

      zainchen.json = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "2.0.2";
          hash = "sha256-nC3Q8KuCtn/jg1j/NaAxWGvnKe/ykrPm2PUjfsJz8aI=";
          name = "json";
          publisher = "ZainChen";
        };

        meta = {
          description = "Visual Studio Code extension for JSON support";
          changelog = "https://marketplace.visualstudio.com/items/ZainChen.json/changelog";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.rhoriguchi ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ZainChen.json";
        };
      };

      zguolee.tabler-icons = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.4.2";
          hash = "sha256-2PKMyK8XYIjuoD1InrNaWZTP29LcPYetP8pmXRK/zYg=";
          name = "tabler-icons";
          publisher = "zguolee";
        };

        meta = {
          description = "Tabler product icon theme for Visual Studio Code";
          homepage = "https://github.com/zguolee/vscode-tabler-icons";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=zguolee.tabler-icons";
        };
      };

      zhuangtongfa.material-theme = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "3.19.0";
          name = "material-theme";
          publisher = "zhuangtongfa";
          sha256 = "sha256-K0eXeAEn4s3YZHJJU9jxtytNQTgaGwvd3fBUsZiKfPw=";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };

      zhwu95.riscv = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.0.8";
          hash = "sha256-PXaHSEXoN0ZboHIoDg37tZ+Gv6xFXP4wGBS3YS/53TY=";
          name = "riscv";
          publisher = "zhwu95";
        };

        meta = {
          description = "Basic RISC-V colorization and snippets support";
          homepage = "https://github.com/zhuanhao-wu/vscode-riscv-support";
          license = lib.licenses.mit;
          maintainers = [ lib.maintainers.CardboardTurkey ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=zhwu95.riscv";
        };
      };

      ziglang.vscode-zig = buildVscodeMarketplaceExtension {
        mktplcRef = {
          version = "0.6.18";
          hash = "sha256-jn/2Nmz6N84BCWnRdnM8w5AdiF2hh55h39SDTmRry5I=";
          name = "vscode-zig";
          publisher = "ziglang";
        };

        meta = {
          description = "Zig support for Visual Studio Code";
          homepage = "https://github.com/ziglang/vscode-zig";
          changelog = "https://marketplace.visualstudio.com/items/ziglang.vscode-zig/changelog";
          license = lib.licenses.mit;
          maintainers = [ ];
          downloadPage = "https://marketplace.visualstudio.com/items?itemName=ziglang.vscode-zig";
        };
      };

      zxh404.vscode-proto3 = buildVscodeMarketplaceExtension {
        nativeBuildInputs = [
          jq
          moreutils
        ];

        postInstall = ''
          cd "$out/$installPrefix"
          jq '.contributes.configuration.properties.protoc.properties.path.default = "${protobuf}/bin/protoc"' package.json | sponge package.json
        '';

        mktplcRef = {
          version = "0.5.5";
          name = "vscode-proto3";
          publisher = "zxh404";
          sha256 = "sha256-Em+w3FyJLXrpVAe9N7zsHRoMcpvl+psmG1new7nA8iE=";
        };

        meta = {
          license = lib.licenses.mit;
        };
      };
    };

  aliases = super: {
    Arjun.swagger-viewer = throw "Arjun.swagger-viewer is deprecated in favor of arjun.swagger-viewer"; # Added 2024-05-29
    WakaTime.vscode-wakatime = throw "WakaTime.vscode-wakatime is deprecated in favor of wakatime.vscode-wakatime"; # Added 2024-05-29
    _13xforever = throw "_13xforever is deprecated in favor of 13xforever"; # Added 2024-05-29
    _1Password = throw "_1Password is deprecated in favor of 1Password"; # Added 2024-05-29
    _2gua = throw "_2gua is deprecated in favor of 2gua"; # Added 2024-05-29
    _4ops = throw "_4ops is deprecated in favor of 4ops"; # Added 2024-05-29
    dendron.dendron-markdown-preview-enhanced = throw "dendron.dendron-markdown-preview-enhanced has been removed from the VSCode marketplace."; # Added 2025-08-21
    equinusocio.vsc-material-theme = throw "'equinusocio.vsc-material-theme' has been removed due to security concerns. The extension contained potentially malicious code and was taken down."; # Added 2025-02-28
    equinusocio.vsc-material-theme-icons = throw "'equinusocio.vsc-material-theme-icons' has been removed due to security concerns. The extension contained potentially malicious code and was taken down."; # Added 2025-02-28
    influxdata.flux = throw "'influxdata.flux' has been removed due to being unmaintained upstream"; # Added 2025-12-09
    jakebecker.elixir-ls = throw "jakebecker.elixir-ls is deprecated in favor of elixir-lsp.vscode-elixir-ls"; # Added 2024-05-29
    jpoissonnier.vscode-styled-components = throw "jpoissonnier.vscode-styled-components is deprecated in favor of styled-components.vscode-styled-components"; # Added 2024-05-29
    matklad.rust-analyzer = throw "matklad.rust-analyzer is deprecated in favor of rust-lang.rust-analyzer"; # Added 2024-05-29
    mgt19937.typst-preview = throw "The features of 'typst-preview' have been consolidated to 'tinymist', an all-in-one language server for typst"; # Added 2024-07-07
    ms-vscode.PowerShell = throw "ms-vscode.PowerShell is deprecated in favor of super.ms-vscode.powershell"; # Added 2024-05-29
    ms-vscode.go = throw "ms-vscode.go is deprecated in favor of golang.go"; # Added 2024-05-29
    ms-vscode.theme-tomorrowkit = throw "ms-vscode.theme-tomorrowkit is deprecated"; # Added 2025-08-30
    richie5um2.snake-trail = throw "richie5um2.snake-trail is deprecated"; # Added 2025-09-04
    rioj7.commandOnAllFiles = throw "rioj7.commandOnAllFiles is deprecated in favor of rioj7.commandonallfiles"; # Added 2024-05-29
  };

  # TODO: add overrides overlay, so that we can have a generated.nix
  # then apply extension specific modifications to packages.

  # overlays will be applied left to right, overrides should come after aliases.
  overlays = lib.optionals config.allowAliases [
    (self: super: lib.recursiveUpdate super (aliases super))
  ];

  toFix = lib.foldl' (lib.flip lib.extends) baseExtensions overlays;
in
lib.fix toFix
