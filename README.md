# MDP_Project
python ./FactorFlow/main_cli.py eyeriss-conv 4 4 4 4 3 3 > ./output/FF_output.txt


python ./FactorFlow/main_cli.py eyeriss 8 8 8 > ./output/FF_output.txt

python ./FactorFlow/main_cli.py eyeriss-conv 8 8 8 8 3 3 > ./output/FF_output.txt

python src/generator.py

gcc -o test_cpu generated_for_cpu.c -lm -O2

./test_cpu

./compile_bambu.sh