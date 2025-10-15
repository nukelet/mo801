# MO801 Simulação em Nível de Arquitetura

# Atividade L1: Spike

O objetivo dessa atividade é praticar o uso do simulador Spike (riscv-isa-sim), implementação de referência do conjunto de instruções RISC-V.

## Parte 0: Preparação do ambiente

O ambiente básico de simulação necessita da ferramenta de compilação RISC-V GNU Toolchain, Simulador Spike e RISC-V Proxy kernel.

- [RISC-V GNU Toolchain: https://github.com/riscv-collab/riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [Spike: https://github.com/riscv-software-src/riscv-isa-sim](https://github.com/riscv-software-src/riscv-isa-sim)
- [RISC-V Proxy Kernel: https://github.com/riscv-software-src/riscv-pk](https://github.com/riscv-software-src/riscv-pk)

O ambiente foi testado em Ubuntu 24.04 rodando em arquitetura Intel e Arm (Apple M1). A utilização de um container exclusivo é recomendada.

Sequência rápida de instalação:

```bash
# Instalação de dependências
sudo apt install autoconf automake autotools-dev curl python3 python3-pip python3-tomli libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev device-tree-compiler libboost-regex-dev libboost-system-dev git

# Clone dos respositórios
git clone https://github.com/riscv-collab/riscv-gnu-toolchain.git
git clone https://github.com/riscv-software-src/riscv-isa-sim.git
git clone https://github.com/riscv-software-src/riscv-pk.git

# Definição da variável de ambiente RISCV para o caminho de instalação
export RISCV=$HOME/riscv

# Instalação do Toolchain
# Atenção: demora vários minutos
cd riscv-gnu-toolchain
./configure --prefix=$RISCV
make
export PATH=$PATH:$RISCV/bin
cd -

# Instalação do Spike
mkdir -p riscv-isa-sim/build
cd riscv-isa-sim/build
../configure --prefix=$RISCV
make
make install
cd -

#Instalação do PK
mkdir -p riscv-pk/build
cd riscv-pk/build
../configure --prefix=$RISCV --host=riscv64-unknown-elf
make
make install
cd -

```

## Parte 1: Hello, Spike

Teste a execução no Spike usando um "Hello world" simples.

```bash
# Compilando o programa para RISC-V
riscv64-unknown-elf-gcc -o hello.rv hello.c

# Executando no Spike
spike pk hello.rv
```

Se tudo estiver correto, você deve ver a mensagem escrita na tela como resultado da simulação.

Execute o Spike sem indicar nenhum programa para execução (apenas `spike`) e observe os possíveis parâmetros que podem ser indicados ao simulador para personalização dos resultados. Teste alguns deles com o arquivo de "Hello world", por exemplo, `-l`, `-g`, `--log-commits`. Note que esses parâmetros devem ser passados para o próprio Spike, e portanto aparecem logo após o nome do simulador na linha de comando.

```bash
spike -l pk hello.rv
```

Observe os parâmetros para configuração de cache `--ic`, `--dc` e `--l2`. Teste a execução do seu programa com algumas configurações diferentes de cache, utilizando a tabela abaixo como referência. Analise os resultados de número de acessos e taxa de misses, criando tabelas e gráficos. Comente sobre o impacto esperado no tempo de execução para as configurações de cache escolhidas em comparação com uma alternativa sem cache.

| Tamanho total da cache | Nº de conjuntos | Nº de vias | Tamanho do bloco |
|----|----|----|----|
| 8 KB | 256 | 1 | 32 B |
| 8 KB | 128 | 2 | 32 B |
| 8 KB | 64 | 4 | 32 B |
| 8 KB | 64 | 2 | 64 B |
| 16 KB | 128 | 2 | 64 B |
| 32 KB | 256 | 2 | 64 B |
| 32 KB | 128 | 2 | 128 B |
| 512 KB | 16384 | 1 | 32 B |
| 512 KB | 8192 | 2 | 32 B |
| 512 KB | 4096 | 4 | 32 B |
| 512 KB | 4096 | 2 | 64 B |
| 1 MB | 8192 | 2 | 64 B |
| 2 MB | 16384 | 2 | 64 B |
| 2 MB | 8192 | 2 | 128 B |

## Parte 2: Multiplicando matrizes

O objetivo principal desta etapa é avaliar o desempenho de diferentes padrões de acesso à memória para execução de uma rotina de multiplicação de matrizes.

1. Crie um programa em C para fazer a multiplicação de duas matrizes quadradas ($C[M][N] = A[M][K] * B[K][N]$, em que $M=N=K$) de elementos reais (`float`). Utilize no seu código a abordagem de multiplicação ingênua de três laços aninhados iterando sobre as dimensões M, N e K. Note que limitações de memória do Spike limitam as dimensões das matrizes. Valores de $M=N=K=256$ ou $M=N=K=512$ devem ser seguros. Mantenha a rotina principal de multiplicação de matrizes em uma função exclusiva para facilitar as análises a seguir.

2. Utilize o log de execução do Spike (`spike -l`) para contabilizar o número de instruções executadas pelo programa. Isole na contagem apenas as instruções executadas durante a rotina principal de multiplicação. *Dica:* utilize um disassembly do programa `riscv64-unknown-elf-objdump -D mmult.rv` para extrair o intervalo que faz parte da rotina principal.

3. Analise o comportamento do programa executando com diferentes configurações de cache, assim como na Parte 1, montando tabelas e gráficos com os resultados. O comportamento é diferente do programa simples de "Hello world"? Por quê?

4. Fixando uma configuração satisfatória de cache, repita o experimento recompilando o programa usando diferentes configurações de otimização do compilador (pelo menos, `-O2` e `-O3`). Que impacto elas causam na contagem de instruções e desempenho de cache?

5. Fixando configurações de cache e otimização satisfatórias, reescreva seu programa para iterar sobre as dimensões M, N e K em ordens distintas. Ou seja, uma das opções é iterar sobre a dimensão K no laço mais externo e sobre a M no laço mais interno, por exemplo. Qual impacto essa alteração causa no programa? Discuta sobre como essa alteração se reflete nos padrões de acesso à memória e utilização de cache.

6. Proponha alterações no padrão de acesso ou na organização dos dados em memória que favoreçam a exploração da cache. Implemente sua solução no programa e avalie o desempenho. *Dica: considere transposição das matrizes e/ou acessos em blocos menores.*

## Parte 3: Modificando instruções

**Em breve...**
