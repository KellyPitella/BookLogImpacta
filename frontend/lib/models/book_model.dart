class BookModel {
  final int id;
  final String titulo;
  final String? autor;
  final String? genero;
  final int totalPaginas;
  final int paginasLidas;
  final bool concluido;
  final bool favorito;
  final String status;
  final DateTime dataCadastro;
  final double percentual;
  final String? capaArquivo;

  BookModel({
    required this.id,
    required this.titulo,
    this.autor,
    this.genero,
    required this.totalPaginas,
    required this.paginasLidas,
    required this.concluido,
    this.favorito = false,
    this.status = 'QueroLer',
    required this.dataCadastro,
    required this.percentual,
    this.capaArquivo,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: json['id'] as int,
      titulo: json['titulo'] as String,
      autor: json['autor'] as String?,
      genero: json['genero'] as String?,
      totalPaginas: json['totalPaginas'] as int,
      paginasLidas: json['paginasLidas'] as int,
      concluido: json['concluido'] as bool,
      favorito: json['favorito'] as bool? ?? false,
      status: json['status'] as String? ?? 'QueroLer',
      dataCadastro: DateTime.parse(json['dataCadastro'] as String),
      percentual: (json['percentual'] as num).toDouble(),
      capaArquivo: json['capaArquivo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'genero': genero,
      'totalPaginas': totalPaginas,
      'paginasLidas': paginasLidas,
      'concluido': concluido,
      'favorito': favorito,
      'status': status,
      'dataCadastro': dataCadastro.toIso8601String(),
      'percentual': percentual,
      'capaArquivo': capaArquivo,
    };
  }

  double get progressFactor =>
      totalPaginas > 0 ? (paginasLidas / totalPaginas).clamp(0.0, 1.0) : 0.0;

  int get percentualInt => percentual.round();

  BookModel copyWith({
    int? id,
    String? titulo,
    String? autor,
    String? genero,
    int? totalPaginas,
    int? paginasLidas,
    bool? concluido,
    bool? favorito,
    String? status,
    DateTime? dataCadastro,
    double? percentual,
    String? capaArquivo,
  }) {
    return BookModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      genero: genero ?? this.genero,
      totalPaginas: totalPaginas ?? this.totalPaginas,
      paginasLidas: paginasLidas ?? this.paginasLidas,
      concluido: concluido ?? this.concluido,
      favorito: favorito ?? this.favorito,
      status: status ?? this.status,
      dataCadastro: dataCadastro ?? this.dataCadastro,
      percentual: percentual ?? this.percentual,
      capaArquivo: capaArquivo ?? this.capaArquivo,
    );
  }
}
