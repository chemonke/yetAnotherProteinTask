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
          aria2
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
	    absl-py
	    docker
	    pdb2pqr
	    gemmi
          ]))
          gcc13
        ];
        shellHook = ''
          export CC=${pkgs.gcc13}/bin/gcc
          export CXX=${pkgs.gcc13}/bin/g++

          export CUDA_PATH=${pkgs.cudatoolkit}
          export LD_LIBRARY_PATH=${
            pkgs.lib.makeLibraryPath [
              "/run/opengl-driver"
              pkgs.cudatoolkit
              pkgs.cudaPackages.cudnn
            ]
          }:$LD_LIBRARY_PATH
        '';
      };

      # Add nixosConfigurations for system-level config
      nixosConfigurations.${system} = nixpkgs.lib.nixosSystem {
        system = "${system}";
        modules = [
          ({ config, pkgs, ... }: {
            # Enable NVIDIA driver
            hardware.nvidia.enable = true;

            # Enable NVIDIA container toolkit
            hardware.nvidia-container-toolkit.enable = true;

            # Docker with NVIDIA runtime enabled
            virtualisation.docker.enable = true;
            virtualisation.docker.enableNvidia = true;

            # Add system packages so nvidia-container-cli is globally available
            environment.systemPackages = with pkgs; [
              nvidia-container-toolkit
              nvidia-docker
            ];

            # Allow unfree for NVIDIA drivers
            nixpkgs.config.allowUnfree = true;
          })
        ];
      };
    };
}
