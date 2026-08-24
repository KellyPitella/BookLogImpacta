using Microsoft.EntityFrameworkCore;
using BookLog.Data;
using BookLog.DTOs;
using BookLog.Models;

namespace BookLog.Services;

public class LivroService
{
    private readonly BookLogContext _context;

    public LivroService(BookLogContext context)
    {
        _context = context;
    }

    public async Task<List<LivroDto>> GetLivrosPorUsuario(int usuarioId)
    {
        return await _context.Livros
            .Where(l => l.UsuarioId == usuarioId)
            .Select(l => new LivroDto
            {
                Id = l.Id,
                Titulo = l.Titulo,
                Autor = l.Autor,
                Genero = l.Genero,
                TotalPaginas = l.TotalPaginas,
                DataCadastro = l.DataCadastro
            })
            .OrderByDescending(l => l.DataCadastro)
            .ToListAsync();
    }

    public async Task<LivroDto> CreateLivro(
        CreateLivroDto dto,
        int usuarioId)
    {
        var livro = new Livro
        {
            Titulo = dto.Titulo,
            Autor = dto.Autor,
            Genero = dto.Genero,
            TotalPaginas = dto.TotalPaginas,
            UsuarioId = usuarioId
        };

        _context.Livros.Add(livro);

        await _context.SaveChangesAsync();

        return new LivroDto
        {
            Id = livro.Id,
            Titulo = livro.Titulo,
            Autor = livro.Autor,
            Genero = livro.Genero,
            TotalPaginas = livro.TotalPaginas,
            DataCadastro = livro.DataCadastro
        };
    }
}