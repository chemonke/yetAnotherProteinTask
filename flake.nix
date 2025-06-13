{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;

        config = {
          allowUnfree  = true;
          cudaSupport  = true;
        };
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
	    libsvm
          (python312.withPackages (ps: with ps; [
            ipython
            ipykernel
            jupyter
            numpy
            pandas
            matplotlib
            seaborn
            scikit-learn
            torch
            biopython
            propka
          ]))
          gcc13
        ];
        shellHook = ''
          # Use GCC 13 so nvcc picks a compatible compiler
          export CC=${pkgs.gcc13}/bin/gcc
          export CXX=${pkgs.gcc13}/bin/g++

          # If you build custom CUDA code, make sure CUDA_PATH is set
          export CUDA_PATH=${pkgs.cudatoolkit}

          # Extend dynamic linker path for OpenGL & CUDA (needed only when
          # compiling your own kernels)
          export LD_LIBRARY_PATH=${
            pkgs.lib.makeLibraryPath [
              "/run/opengl-driver"   # libGL.so from the running driver
              pkgs.cudatoolkit
              pkgs.cudaPackages.cudnn
            ]
          }:$LD_LIBRARY_PATH
        '';
      };
    };
}
