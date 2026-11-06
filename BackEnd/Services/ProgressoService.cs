using Microsoft.EntityFrameworkCore;
using BookLog.Data;
using BookLog.DTOs;
using BookLog.Models;

namespace BookLog.Services;

public class ProgressoService
{
    private readonly BookLogContext _context;

    public ProgressoService(BookLogContext context)
    {
        _context = context;
    }

    public async Task<ProgressoLeituraDto?> Registrar(
        CreateProgressoDto dto,
        int usuarioId)
    {
        var livro = await _context.Livros.FirstOrDefaultAsync(
            item => item.Id == dto.LivroId && item.UsuarioId == usuarioId);

        if (livro is null) return null;

        if (livro.PaginasLidas + dto.PaginasLidas > livro.TotalPaginas)
        {
            throw new ArgumentException(
                "O progresso não pode ultrapassar o total de páginas do livro.");
        }

        var progresso = new ProgressoLeitura
        {
            Data = dto.Data,
            PaginasLidas = dto.PaginasLidas,
            Nota = dto.Nota,
            LivroId = livro.Id,
            Livro = livro
        };

        livro.PaginasLidas += dto.PaginasLidas;
        livro.Concluido = livro.PaginasLidas >= livro.TotalPaginas;
        _context.ProgressosLeitura.Add(progresso);
        await _context.SaveChangesAsync();

        return ToDto(progresso);
    }

    public async Task<List<ProgressoLeituraDto>?> GetPorLivro(
        int livroId,
        int usuarioId)
    {
        var livroExiste = await _context.Livros.AnyAsync(
            item => item.Id == livroId && item.UsuarioId == usuarioId);

        if (!livroExiste) return null;

        return await _context.ProgressosLeitura
            .Where(item => item.LivroId == livroId)
            .OrderByDescending(item => item.Data)
            .Select(item => new ProgressoLeituraDto
            {
                Id = item.Id,
                Data = item.Data,
                PaginasLidas = item.PaginasLidas,
                Nota = item.Nota,
                LivroId = item.LivroId,
                LivroTitulo = item.Livro.Titulo
            })
            .ToListAsync();
    }

    public async Task<ResumoLeituraDto> GetResumo(int usuarioId)
    {
        var livros = _context.Livros.Where(item => item.UsuarioId == usuarioId);
        var progressos = _context.ProgressosLeitura
            .Where(item => item.Livro.UsuarioId == usuarioId);

        return new ResumoLeituraDto
        {
            TotalLivros = await livros.CountAsync(),
            LivrosConcluidos = await livros.CountAsync(item => item.Concluido),
            TotalPaginasLidas = await livros.SumAsync(item => (int?)item.PaginasLidas) ?? 0,
            LivrosEmAndamento = await livros.CountAsync(
                item => item.PaginasLidas > 0 && !item.Concluido),
            UltimosRegistros = await progressos
                .OrderByDescending(item => item.Data)
                .Take(10)
                .Select(item => new ProgressoLeituraDto
                {
                    Id = item.Id,
                    Data = item.Data,
                    PaginasLidas = item.PaginasLidas,
                    Nota = item.Nota,
                    LivroId = item.LivroId,
                    LivroTitulo = item.Livro.Titulo
                })
                .ToListAsync()
        };
    }

    public async Task<EstatisticasLeituraDto> GetEstatisticas(
        int ano,
        int usuarioId)
    {
        var livros = await _context.Livros
                .AsNoTracking()
                .Where(item => item.UsuarioId == usuarioId)
                .Select(item => new
                {
                    item.Id,
                    item.TotalPaginas,
                    item.Concluido
                })
                .ToListAsync();

        var progressos = await _context.ProgressosLeitura
                .AsNoTracking()
                .Where(item => item.Livro.UsuarioId == usuarioId)
                .Select(item => new
                {
                    item.Id,
                    item.LivroId,
                    item.Data,
                    item.PaginasLidas
                })
                .OrderBy(item => item.LivroId)
                .ThenBy(item => item.Data)
                .ThenBy(item => item.Id)
                .ToListAsync();

        var progressosPorLivro = progressos
                .GroupBy(item => item.LivroId)
                .ToDictionary(group => group.Key, group => group.ToList());
        var datasConclusao = new Dictionary<int, DateOnly>();
        var livrosConcluidosSemData = 0;

        foreach (var livro in livros.Where(item => item.Concluido))
        {
                if (!progressosPorLivro.TryGetValue(livro.Id, out var historico))
                {
                    livrosConcluidosSemData++;
                    continue;
                }

                long paginasAcumuladas = 0;
                DateOnly? dataConclusao = null;
                foreach (var progresso in historico)
                {
                    paginasAcumuladas += progresso.PaginasLidas;
                    if (paginasAcumuladas >= livro.TotalPaginas)
                    {
                        dataConclusao = DateOnly.FromDateTime(progresso.Data);
                        break;
                    }
                }

                if (dataConclusao is null)
                {
                    livrosConcluidosSemData++;
                }
                else
                {
                    datasConclusao.Add(livro.Id, dataConclusao.Value);
                }
        }

        var leiturasDoAno = progressos
                .Where(item => item.Data.Year == ano)
                .ToList();
        var livrosConcluidosDoAno = livros
                .Where(item =>
                    item.Concluido &&
                    datasConclusao.TryGetValue(item.Id, out var data) &&
                    data.Year == ano)
                .ToList();
        var atividade = leiturasDoAno
                .GroupBy(item => DateOnly.FromDateTime(item.Data))
                .Select(group => new AtividadeLeituraDto
                {
                    Data = group.Key,
                    PaginasLidas = group.Sum(item => (long)item.PaginasLidas)
                })
                .OrderBy(item => item.Data)
                .ToList();
        var paginasPorDia = atividade.ToDictionary(
                item => item.Data,
                item => item.PaginasLidas);
        var diasOrdenados = paginasPorDia.Keys.OrderBy(item => item).ToList();
        var maiorSequencia = 0;
        var sequenciaAtual = 0;
        DateOnly? diaAnterior = null;

        foreach (var dia in diasOrdenados)
        {
                sequenciaAtual = diaAnterior is not null &&
                    dia.DayNumber == diaAnterior.Value.DayNumber + 1
                        ? sequenciaAtual + 1
                        : 1;
                maiorSequencia = Math.Max(maiorSequencia, sequenciaAtual);
                diaAnterior = dia;
        }

        var paginasPorMes = leiturasDoAno
                .GroupBy(item => item.Data.Month)
                .ToDictionary(
                    group => group.Key,
                    group => group.Sum(item => (long)item.PaginasLidas));
        var concluidosPorMes = livrosConcluidosDoAno
                .GroupBy(item => datasConclusao[item.Id].Month)
                .ToDictionary(group => group.Key, group => group.Count());
        var paginasLidasNoAno = leiturasDoAno.Sum(
                item => (long)item.PaginasLidas);

        return new EstatisticasLeituraDto
        {
                Ano = ano,
                LivrosConcluidos = livrosConcluidosDoAno.Count,
                PaginasLidas = paginasLidasNoAno,
                MediaDiaria = atividade.Count == 0
                    ? 0
                    : Math.Round((double)paginasLidasNoAno / atividade.Count, 1),
                MediaPorLivro = livrosConcluidosDoAno.Count == 0
                    ? 0
                    : Math.Round(
                        livrosConcluidosDoAno.Sum(item => (double)item.TotalPaginas) /
                        livrosConcluidosDoAno.Count,
                        1),
                DiasDeLeitura = atividade.Count,
                MaiorSequencia = maiorSequencia,
                LivrosConcluidosSemData = livrosConcluidosSemData,
                AnosDisponiveis = progressos
                    .Select(item => item.Data.Year)
                    .Append(DateTime.UtcNow.Year)
                    .Distinct()
                    .OrderByDescending(item => item)
                    .ToList(),
                Meses = Enumerable.Range(1, 12)
                    .Select(mes => new EstatisticaMensalDto
                    {
                        Mes = mes,
                        LivrosConcluidos = concluidosPorMes.GetValueOrDefault(mes),
                        PaginasLidas = paginasPorMes.GetValueOrDefault(mes)
                    })
                    .ToList(),
                Atividade = atividade
        };
    }

    private static ProgressoLeituraDto ToDto(ProgressoLeitura progresso)
    {
        return new ProgressoLeituraDto
        {
            Id = progresso.Id,
            Data = progresso.Data,
            PaginasLidas = progresso.PaginasLidas,
            Nota = progresso.Nota,
            LivroId = progresso.LivroId,
            LivroTitulo = progresso.Livro.Titulo
        };
    }
}