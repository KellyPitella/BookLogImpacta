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