# MO801 Simulação em Nível de Arquitetura

# Atividade L2: QEMU

O objetivo dessa atividade é praticar o uso do emulador QEMU para representação de novas instruções RISC-V e extração de métricas.

## Parte 0: Preparação do ambiente

O ambiente básico de simulação necessita da ferramenta de compilação (mesma da atividade L1), QEMU e dependências.

- [RISC-V GNU Toolchain: https://github.com/riscv-collab/riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [QEMU](https://gitlab.com/qemu-project/qemu)

O ambiente foi testado para versão v10.1.0 do QEMU em Ubuntu 24.04 rodando em arquitetura Intel e Arm (Apple M1). A utilização de um container exclusivo é recomendada.

Sequência rápida de instalação, assumindo utilização do mesmo container com o RISC-V GNU Toolchain da atividade L1.

```bash
# Instalação de dependências
sudo apt install git libglib2.0-dev libfdt-dev libpixman-1-dev zlib1g-dev ninja-build

# Clone dos respositórios
git clone https://gitlab.com/qemu-project/qemu.git

# Compilação do QEMU
cd qemu
git checkout v10.1.0
mkdir build
cd build
../configure --target-list=riscv64-linux-user
make

```

Após a compilação, o binário para execução do QEMU está localizado em `qemu/build/qemu-riscv64`.

## Parte 1: Hello, QEMU

Teste a execução no Spike usando um "Hello world" simples.

```bash
# Compilando o programa para RISC-V
riscv64-unknown-elf-gcc -o hello.rv hello.c

# Executando no Spike
./qemu-riscv64 hello.rv
```

Se tudo estiver correto, você deve ver a mensagem escrita na tela como resultado da simulação.

Execute o QEMU com opção `-h` (apenas `qemu-riscv64 -h`) e observe os possíveis parâmetros que podem ser indicados ao simulador para personalização dos resultados. Teste algumas opções de logging com `-d` e observe os traces gerados.

```bash
./qemu-riscv64 -d in_asm,exec,cpu hello.rv
```


## Parte 2: Entendendo instruções customizadas

O objetivo principal desta etapa é avaliar funcionalmente instruções customizadas no QEMU.

1. Observe os arquivos no diretório `bitcnt` deste repositório. O arquivo `qemu_tras_bitcnt.c` contém a especificação comportamental da isntrução `bitcnt`. O arquivo `bitcnt.c` contém um programa de teste. O arquivo `bitcnt_wrapper.s` contém uma função de wrapper para chamar a instrução customizada. Tente descrever a funcionalidade implementada em cada um dos arquivos.

2. Adicione a linha abaixo ao arquivo `target/riscv/insn32.decode` do QEMU para incluir a codificação da instrução `bitcnt`. A linha indica uma instrução do Tipo R (ou seja, recebe dois registradores como parâmetros e escreve em 1 - veja a documentação da ISA RISC-V) e a codificação dos campos que identificam a operação. Os valores foram definidos arbitrariamente conforme valores disponíveis. É conveniente adicionar a linha junto às demais instruções do Tipo R, como por exemplo logo após o `and` (linha 168).

```
bitcnt   1111111 .....    ..... 111 ..... 0110011 @r
```

3. Copie o conteúdo do arquivo `qemu_tras_bitcnt.c` para o final do arquivo `target/riscv/insn_trans/trans_rvi.c.inc` do QEMU para incluir o comportamento da instrução. Recompile o QEMU utilizando `make` dentro do diretório `build` para habilitar a nova instrução.

4. Compile e execute o programa de teste.

```bash
riscv64-unknown-elf-gcc -c bitcnt.c
riscv64-unknown-elf-gcc -c bitcnt_wrapper.s
riscv64-unknown-elf-gcc -o bitcnt.rv bitcnt_wrapper.o bitcnt.o
./qemu-riscv64 bitcnt.rv 2 3

```
Você deveria ver a mensagem `Bit Count: 3` como resultado. Repita a execução com os parâmetros adicionais da Parte 1 e observe os traces apresentados. O comportamento da instrução era o esperado após a análise do código?

## Parte 3. Criando instruções customizadas

Tomando como base a implementação da instrução `bitcnt` e a [documentação do mecanismo TCG do QEMU](https://wiki.qemu.org/Documentation/TCG/frontend-ops), crie e teste instruções customizadas para as tarefas abaixo.

1. `bitrev` (Bit Reverse): Inverte a ordem de bits de um registrador.
Exemplo: Entrada: `0b10110000` -> Saída: `0b00001101`

2. `clz`/`ctz` (Count Leading/Trailing Zeros): Conta o número de zeros à esquerda (`clz`) ou à direita (`ctz`) de um registrador.
Exemplo: `clz(0b00010000)` -> 3, `ctz(0b00100000)` -> 5

3. `multmod` (Multiply Modular): Executa a operação de multiplicação in-place modular $C = (C * A) % B$.
Exemplo: `multmod a0, a1, a2` -> a0 = (a0 * a1) % a2.

## Apresentação e avaliação dos resultados

Prepare uma apresentação curta (1-2 slides) contendo a visão geral das implementações das instruções customizadas da Parte 3. Comente decisões de projeto e dificuldades encontradas.

Essa apresentação fará parte da sua apresentação de proposta de projeto final, a ser agendada em Outubro.
