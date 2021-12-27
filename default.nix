{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  cl-project = lispPackages.buildLispPackage rec {
    baseName = "cl-project";
    version = "2020-06-16";
    description = "A Common Lisp ASDF project generator.";
    deps = with lispPackages; [
      cl-emb uiop cl-ppcre local-time prove
    ];
    src = fetchFromGitHub {
      owner = "fukamachi";
      repo = "cl-project";
      rev = "151107014e534fc4666222d57fec2cc8549c8814";
      sha256 = "1rmh6s1ncv8s2yrr14ja9wisgg745sq6xibqwb341ikdicxdp26y";
    };
    buildSystems = [ "cl-project" ];
    packageName = "cl-project";
    parasites = [ "cl-project-test" ];
    asdFilesToKeep = [ "cl-project.asd" ];
  };
in
stdenv.mkDerivation {
  pname = "cl-nix-project";
  version = "0.0.1";
  buildDependencies = [ sbcl lispPackages.clwrapper ];
  buildInputs = [ cl-project lispPackages.split-sequence ];
  src = ./.;
  buildPhase = ''
    ${lispPackages.clwrapper}/bin/common-lisp.sh \
      --eval '(asdf:load-system :cl-project)' \
      --eval '(asdf:load-system :split-sequence)' \
      --eval '(load #P"./cl-nix-project.lisp")' \
      --eval '(cl-nix-project::dump-image)'
  '';
  installPhase = ''
    mkdir -p $out/bin
    cp cl-nix-project $out/bin/
  '';
  dontStrip = true;
}
