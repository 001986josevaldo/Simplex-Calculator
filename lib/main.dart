import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const SimplexApp());
}

class SimplexApp extends StatelessWidget {
  const SimplexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Otimização Agrícola',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const OtimizacaoScreen(),
    );
  }
}

class OtimizacaoScreen extends StatefulWidget {
  const OtimizacaoScreen({super.key});

  @override
  State<OtimizacaoScreen> createState() => _OtimizacaoScreenState();
}

class _OtimizacaoScreenState extends State<OtimizacaoScreen> {
  // Controladores para os inputs (Valores iniciais baseados no seu problema)
  // Função Objetivo
  final _lucroSojaController = TextEditingController(text: "1800");
  final _lucroMilhoController = TextEditingController(text: "1500");

  // Restrição 1: Terra
  final _terraSojaController = TextEditingController(text: "1");
  final _terraMilhoController = TextEditingController(text: "1");
  final _terraTotalController = TextEditingController(text: "100");

  // Restrição 2: Água
  final _aguaSojaController = TextEditingController(text: "400");
  final _aguaMilhoController = TextEditingController(text: "500");
  final _aguaTotalController = TextEditingController(text: "45000");

  // Restrição 3: Mão de Obra
  final _moSojaController = TextEditingController(text: "8");
  final _moMilhoController = TextEditingController(text: "5");
  final _moTotalController = TextEditingController(text: "750");

  String _resultado = "Clique em calcular para ver a solução ótima.";

  // Função Principal de Cálculo (Lógica Matemática)
  void _calcularOtimizacao() {
    // 1. Converter inputs para números (double)
    try {
      double c1 = double.parse(_lucroSojaController.text); // 1800
      double c2 = double.parse(_lucroMilhoController.text); // 1500

      // Matriz de coeficientes das restrições (Lado esquerdo)
      // [Soja, Milho]
      List<List<double>> A = [
        [
          double.parse(_terraSojaController.text),
          double.parse(_terraMilhoController.text),
        ],
        [
          double.parse(_aguaSojaController.text),
          double.parse(_aguaMilhoController.text),
        ],
        [
          double.parse(_moSojaController.text),
          double.parse(_moMilhoController.text),
        ],
      ];

      // Vetor de limites (Lado direito - b)
      List<double> b = [
        double.parse(_terraTotalController.text),
        double.parse(_aguaTotalController.text),
        double.parse(_moTotalController.text),
      ];

      // 2. Método dos Vértices (Simplificação computacional do Simplex para 2 variáveis)
      // Encontramos todas as intersecções possíveis entre as retas das restrições e os eixos.
      List<Offset> pontosCandidatos = [];

      // Adiciona a origem (0,0)
      pontosCandidatos.add(const Offset(0, 0));

      // Adiciona intersecções com os eixos (quando x1=0 ou x2=0) para cada restrição
      for (int i = 0; i < A.length; i++) {
        if (A[i][0] != 0)
          pontosCandidatos.add(Offset(b[i] / A[i][0], 0)); // Eixo X
        if (A[i][1] != 0)
          pontosCandidatos.add(Offset(0, b[i] / A[i][1])); // Eixo Y
      }

      // Adiciona intersecções entre as linhas das restrições (sistemas lineares 2x2)
      for (int i = 0; i < A.length; i++) {
        for (int j = i + 1; j < A.length; j++) {
          Offset? intersecao = _calcularIntersecao(A[i], b[i], A[j], b[j]);
          if (intersecao != null) {
            pontosCandidatos.add(intersecao);
          }
        }
      }

      // 3. Verificar Viabilidade e Calcular Z
      double maxZ = -1;
      Offset melhorPonto = const Offset(0, 0);
      bool encontrouSolucao = false;

      for (var p in pontosCandidatos) {
        double x1 = p.dx;
        double x2 = p.dy;

        // Verifica não negatividade e se satisfaz TODAS as restrições
        if (x1 >= -0.001 && x2 >= -0.001 && _satisfazRestricoes(x1, x2, A, b)) {
          double z = c1 * x1 + c2 * x2;
          if (z > maxZ) {
            maxZ = z;
            melhorPonto = p;
            encontrouSolucao = true;
          }
        }
      }

      // 4. Exibir Resultado
      setState(() {
        if (encontrouSolucao) {
          _resultado =
              "LUCRO MÁXIMO: R\$ ${maxZ.toStringAsFixed(2)}\n\n"
              "Produzir:\n"
              "• Soja (x1): ${melhorPonto.dx.toStringAsFixed(2)} unidades\n"
              "• Milho (x2): ${melhorPonto.dy.toStringAsFixed(2)} unidades";
        } else {
          _resultado = "Nenhuma solução viável encontrada.";
        }
      });
    } catch (e) {
      setState(() {
        _resultado =
            "Erro nos dados. Verifique se todos os campos são números.";
      });
    }
  }

  // Auxiliar: Resolve sistema linear de 2 equações para achar onde as linhas se cruzam
  Offset? _calcularIntersecao(
    List<double> r1,
    double b1,
    List<double> r2,
    double b2,
  ) {
    // Regra de Cramer ou Substituição
    double det = r1[0] * r2[1] - r1[1] * r2[0];
    if (det.abs() < 1e-9) return null; // Linhas paralelas

    double x = (b1 * r2[1] - r1[1] * b2) / det;
    double y = (r1[0] * b2 - b1 * r2[0]) / det;
    return Offset(x, y);
  }

  // Auxiliar: Verifica se o ponto respeita os limites de terra, água e mão de obra
  bool _satisfazRestricoes(
    double x1,
    double x2,
    List<List<double>> A,
    List<double> b,
  ) {
    // Tolerância para erros de ponto flutuante
    double epsilon = 1e-4;
    for (int i = 0; i < A.length; i++) {
      double valorGasto = A[i][0] * x1 + A[i][1] * x2;
      if (valorGasto > b[i] + epsilon) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Calculadora Simplex")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("1. Função Objetivo ()"),
            Row(
              children: [
                Expanded(
                  child: _buildInput(_lucroSojaController, "Lucro Soja (x1)"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildInput(_lucroMilhoController, "Lucro Milho (x2)"),
                ),
              ],
            ),
            const Divider(height: 30),
            _buildSectionTitle("2. Restrições"),
            _buildConstraintCard(
              "Terra (ha)",
              _terraSojaController,
              _terraMilhoController,
              _terraTotalController,
            ),
            _buildConstraintCard(
              "Água (m³)",
              _aguaSojaController,
              _aguaMilhoController,
              _aguaTotalController,
            ),
            _buildConstraintCard(
              "Mão de Obra (h)",
              _moSojaController,
              _moMilhoController,
              _moTotalController,
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calcularOtimizacao,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "CALCULAR RESULTADO ÓTIMO",
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _resultado,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInput(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
      ),
    );
  }

  Widget _buildConstraintCard(
    String titulo,
    TextEditingController c1,
    TextEditingController c2,
    TextEditingController total,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _buildInput(c1, "Gasto Soja")),
                const SizedBox(width: 5),
                const Text("+"),
                const SizedBox(width: 5),
                Expanded(child: _buildInput(c2, "Gasto Milho")),
                const SizedBox(width: 5),
                const Text("≤"),
                const SizedBox(width: 5),
                Expanded(child: _buildInput(total, "Disponível")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
