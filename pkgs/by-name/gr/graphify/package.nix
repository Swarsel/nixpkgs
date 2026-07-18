{
  lib,
  fetchFromGitHub,
  python3,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "graphify";
  version = "0.4.23";

  src = fetchFromGitHub {
    owner = "safishamsi";
    repo = "graphify";
    tag = "v${version}";
    hash = "sha256-QEzB1tFBqGhpmI7oudMRC1Ia0CDcm+GYt6AgxMA5zDo=";
  };

  __structuredAttrs = true;

  build-system = [
    python3.pkgs.setuptools
  ];

  dependencies =
    with python3.pkgs;
    [
      networkx
      tree-sitter
    ]
    ++ (with python3.pkgs.tree-sitter-grammars; [
      tree-sitter-c
      tree-sitter-c-sharp
      tree-sitter-cpp
      tree-sitter-elixir
      tree-sitter-go
      tree-sitter-java
      tree-sitter-javascript
      tree-sitter-julia
      tree-sitter-kotlin
      tree-sitter-lua
      tree-sitter-objc
      tree-sitter-php
      tree-sitter-powershell
      tree-sitter-python
      tree-sitter-ruby
      tree-sitter-rust
      tree-sitter-scala
      tree-sitter-swift
      tree-sitter-typescript
      tree-sitter-verilog
      tree-sitter-zig
    ]);

  optional-dependencies = with python3.pkgs; {
    leiden = [
      graspologic
    ];

    mcp = [
      mcp
    ];

    neo4j = [
      neo4j
    ];

    office = [
      openpyxl
      python-docx
    ];

    pdf = [
      html2text
      pypdf
    ];

    svg = [
      matplotlib
    ];

    video = [
      faster-whisper
      yt-dlp
    ];

    watch = [
      watchdog
    ];
  };

  pyproject = true;

  meta = {
    description = "AI coding assistant skill. Turn any folder of code, docs, papers, images, or videos into a queryable knowledge graph.";
    homepage = "https://github.com/safishamsi/graphify";
    changelog = "https://github.com/safishamsi/graphify/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ stunkymonkey ];
    mainProgram = "graphify";
  };
}
