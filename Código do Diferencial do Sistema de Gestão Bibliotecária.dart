import 'dart:math';

// -------------------------------------
// DIFERENCIAL: SISTEMA DE HISTÓRICO (LOG)
// -------------------------------------

class OperacaoLog {
  String item;
  String tipo; // "Empréstimo" ou "Devolução"
  DateTime data;
  double? valorPago; // só na devolução

  OperacaoLog(this.item, this.tipo, this.data, {this.valorPago});

  @override
  String toString() {
    String texto = "$tipo - $item - ${data.toString()}";
    if (valorPago != null) {
      texto += " - Pagamento: R\$ ${valorPago!.toStringAsFixed(2)}";
    }
    return texto;
  }
}

// Histórico global
List<OperacaoLog> historico = [];

// -------------------------------------
// CLASSE BASE
// -------------------------------------

class ItemBiblioteca {
  String titulo;
  int anoPublicacao;
  int copias;
  double precoBase;
  double multaDia;
  DateTime? dataEmprestimo;

  ItemBiblioteca(
    this.titulo,
    this.anoPublicacao,
    this.copias,
    this.precoBase,
    this.multaDia,
  );

  bool emprestar() {
    if (copias > 0) {
      copias--;
      dataEmprestimo = DateTime.now();

      // REGISTRA NO HISTÓRICO
      historico.add(
        OperacaoLog(titulo, "Empréstimo", DateTime.now()),
      );

      return true;
    }
    return false;
  }

  double devolver() {
    if (dataEmprestimo == null) {
      print("Este item não foi emprestado!");
      return 0.0;
    }

    copias++;
    DateTime devolucao = DateTime.now();
    int diasAtraso = devolucao.difference(dataEmprestimo!).inDays;

    double pagamento =
        precoBase + (diasAtraso > 0 ? diasAtraso * multaDia : 0);

    // REGISTRA NO HISTÓRICO
    historico.add(
      OperacaoLog(
        titulo,
        "Devolução",
        DateTime.now(),
        valorPago: pagamento,
      ),
    );

    return pagamento;
  }

  String detalhes() {
    return """
Título: $titulo
Ano: $anoPublicacao
Cópias: $copias
Preço Base: R\$ ${precoBase.toStringAsFixed(2)}
Multa/dia: R\$ ${multaDia.toStringAsFixed(2)}
""";
  }
}

// -------------------------------------
// LIVRO
// -------------------------------------

class Livro extends ItemBiblioteca {
  String autor;
  String isbn;

  Livro(
    String titulo,
    int ano,
    int copias,
    this.autor,
    this.isbn,
  ) : super(titulo, ano, copias, 15.0, 2.5);

  @override
  String detalhes() {
    return """
[LIVRO]
${super.detalhes()}Autor: $autor
ISBN: $isbn
""";
  }
}

// -------------------------------------
// REVISTA
// -------------------------------------

class Revista extends ItemBiblioteca {
  int edicao;
  String mes;

  Revista(
    String titulo,
    int ano,
    int copias,
    this.edicao,
    this.mes,
  ) : super(titulo, ano, copias, 5.0, 1.0);

  @override
  String detalhes() {
    return """
[REVISTA]
${super.detalhes()}Edição: $edicao
Mês: $mes
""";
  }
}

// -------------------------------------
// MAIN – SIMULAÇÃO COMPLETA
// -------------------------------------

void main() {
  List<ItemBiblioteca> acervo = [
    Livro("O Pequeno Príncipe", 1943, 3, "Saint-Exupéry", "978123456789"),
    Livro("1984", 1949, 2, "George Orwell", "978987654321"),
    Livro("Dom Casmurro", 1899, 1, "Machado de Assis", "978112233445"),
    Revista("Superinteressante", 2023, 4, 320, "Outubro"),
    Revista("Veja", 2024, 2, 410, "Janeiro"),
    Revista("National Geographic", 2024, 1, 550, "Dezembro"),
  ];

  print("=== ESTOQUE INICIAL ===");
  for (var item in acervo) {
    print(item.detalhes());
  }

  print("\n=== EMPRÉSTIMO DE 3 LIVROS E 3 REVISTAS ===");
  for (int i = 0; i < 6; i++) {
    bool ok = acervo[i].emprestar();
    print("${acervo[i].titulo} -> ${ok ? "Emprestado" : "Indisponível"}");
  }

  print("\n=== DEVOLUÇÃO E CÁLCULO DE PAGAMENTO ===");
  for (int i = 0; i < 6; i++) {
    double valor = acervo[i].devolver();
    print("${acervo[i].titulo} -> Pagamento: R\$ ${valor.toStringAsFixed(2)}");
  }

  print("\n=== ESTOQUE FINAL ===");
  for (var item in acervo) {
    print(item.detalhes());
  }

  print("\n=== HISTÓRICO DE OPERAÇÕES ===");
  for (var h in historico) {
    print(h);
  }
}
