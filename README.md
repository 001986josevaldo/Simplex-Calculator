# 📊 Flutter Simplex Solver

Um aplicativo móvel desenvolvido em **Flutter** para resolver problemas de Programação Linear utilizando o **Método Simplex Tabular**. O app permite configurar dinamicamente o número de variáveis de decisão e restrições, calculando a solução ótima para maximização de lucros.

## 🚀 Funcionalidades

- **Configuração Dinâmica:** Defina a quantidade de variáveis ($n$) e restrições ($m$) através de sliders interativos.
- **Geração de Interface:** Os campos de entrada são gerados automaticamente baseados na configuração do usuário.
- **Algoritmo Simplex:** Implementação pura em Dart do algoritmo Simplex (sem dependências externas de solvers), capaz de lidar com iterações até encontrar o valor ótimo.
- **Resultados Detalhados:** Exibe o Lucro Máximo ($Z$) e os valores ideais para cada variável de decisão
  ($x_1, x_2, ...$).

## 🛠️ Tecnologias Utilizadas

- **Linguagem:** Dart
- **Framework:** Flutter (Material Design 3)
- **Arquitetura:** MVC (Model-View-Controller) para separação de responsabilidades.
- **Estrutura de Dados:** Listas e Matrizes para manipulação do Tableau Simplex.

## 📱 Capturas de Tela

<div style="display: flex; flex-direction: row;">
  <img src="screenshots/conf_simplex.png" width="250" alt="Tela de Configuração">
  &nbsp; &nbsp; &nbsp; <img src="screenshots/inserir_dados.jpeg" width="250" alt="Tela de Inserção">
</div>

## 🧮 Como Funciona (Lógica)

O núcleo do projeto é a classe `SimplexSolver`, que realiza:

1. Montagem do Tableau inicial com variáveis de folga.
2. Identificação da coluna pivô (maior gradiente positivo/negativo).
3. Teste da razão para identificar a linha pivô.
4. Escalonamento (Gaussian Elimination) até que não existam coeficientes negativos na linha da função objetivo.

## 🏁 Como Rodar o Projeto

```bash
# Clone este repositório
$ git clone https://github.com/001986josevaldo/Simplex-Calculator.git

# Entre na pasta
$ cd flutter-simplex-solver

# Instale as dependências
$ flutter pub get

# Execute o app
$ flutter run
```
